#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../../lib');

use AWS::CLIWrapper;
use Log::Minimal;
use Sub::Retry;
use Getopt::Long;

use Babyry::Common;
use Babyry::Service::Base;

GetOptions(
    'env|e=s' => \my $env,
);
$env ||= 'development';
$ENV{APP_ENV} = $env;
$ENV{DEBUG}   = 1 if $env eq 'local' || $env eq 'development';

my $service_base = Babyry::Service::Base->new;
my $teng         = $service_base->teng('BABYRY_MAIN_R');
my $teng_w       = $service_base->teng('BABYRY_MAIN_W');
my $queue_model  = $service_base->model('image_delete_queue');
my $image_model  = $service_base->model('image');
my $aws          = AWS::CLIWrapper->new;

my $QUEUE_COUNT  = 50;
my $BUCKET       = Babyry::Common->config->{bucket};
my $TRASH_BUCKET = Babyry::Common->config->{trash_bucket};



# queueの多重処理が行われないような対応はしてないので、daemonは1プロセスでしか動かせない
# 複数プロセス使う時はqueue select時に処理中statusにupdateするか、Q4Mを使う

while (1) {
    my $image_ids = get_target_images();
    delete_images_from_s3($image_ids);
    sleep 1;
}

sub get_target_images {

    my $queues = $queue_model->dequeue( $teng, { count => $QUEUE_COUNT } ) || [];
    my $image_ids = [
        map { $_->{image_id} } @$queues
    ];
    return $image_ids;
}

sub delete_images_from_s3 {
    my $image_ids = shift;

    return unless $image_ids && scalar @$image_ids;

    my $image_info = $image_model->get_by_image_ids($teng, $image_ids, { disabled => 1 });

    for my $image_id (@$image_ids) {

        my $user_id  = $image_info->{$image_id}{uploaded_by};
        my $format   = $image_info->{$image_id}{format};

        move_to_trash($image_id, $user_id, $format);

        $teng_w->txn_begin;
        $queue_model->delete_queue_by_id($teng_w, $image_id);
        $teng_w->txn_commit;
    }
}

# 画像をtrashへ保存し、その後外部からアクセス可能なbucketからは削除する
# 途中で失敗した場合はアラートを流したあとqueueを削除する(連続でアラートが飛び続けるため)
# retryする際は手動で再enqueueする
sub move_to_trash {
    my ($image_id, $user_id, $format) = @_;

    my $image_relative_path       = sprintf('%d/%d.%s', $user_id, $image_id, $format);
    my $image_thumb_relative_path = sprintf('%d/%d_thumb.%s', $user_id, $image_id, $format);

    my $copy_param = {
        key           => $image_relative_path,
        bucket        => $TRASH_BUCKET,
        'copy-source' => sprintf('%s/%s', $BUCKET, $image_relative_path),
    };
    my @delete_params = (
        {
            key    => $image_thumb_relative_path,
            bucket => $BUCKET,
        },
        {
            key    => $image_relative_path,
            bucket => $BUCKET,
        },
    );

    # copy to trash
    my $copy_res = request_to_s3('copy-object', $copy_param);
    if (!$copy_res) {
        critf(
            'Failed to copy image to aws trash ERROR_CODE=%s ERROR_MESSAGE:%s image_id:%d',
            $AWS::CLIWrapper::Error->{Code},
            $AWS::CLIWrapper::Error->{Code},
            $image_id
        );
        return;
    }

    # delete from accessible bucket
    for my $param (@delete_params) {

        my $res = request_to_s3('delete-object', $param);
    
        if ( !$res ) {
            # TODO 失敗した場合はretry queueに突っ込んで再処理する
            critf(
                'Failed to delete image from aws ERROR_CODE=%s ERROR_MESSAGE:%s image_id:%d',
                $AWS::CLIWrapper::Error->{Code},
                $AWS::CLIWrapper::Error->{Code},
                $image_id,
            );
            return;
        }
    }
    return 1;
}

sub request_to_s3 {
    my ($service, $param) = @_;
    my $res = retry 3, 1, sub {
        $aws->s3api($service, $param);
    };
    return $res;
}

