#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../../lib');

use Log::Minimal;
use AWS::CLIWrapper;
use Data::Dumper;

use Babyry::Common;
use Babyry::Model::ImageQueue;
use Babyry::Model::Image;

my $aws = AWS::CLIWrapper->new();

my $TMP_BUCKET = Babyry::Common->config->{'tmp_bucket'};
my $BUCKET = Babyry::Common->config->{'bucket'};

require Babyry::Service::Base;
my $teng = Babyry::Service::Base->new()->teng('BABYRY_MAIN_W');
my $teng_r = Babyry::Service::Base->new()->teng('BABYRY_MAIN_R');
my $image_queue = Babyry::Model::ImageQueue->new();
my $image = Babyry::Model::Image->new();
while(1) {
    my $queue = $image_queue->dequeue($teng_r);
    for (@{$queue}) {
        &send_to_s3($_->image_id, $_->image_name);
    }
    sleep 1;
}

sub send_to_s3 {
    my $image_id = shift;
    my $image_name = shift;
    
    my $queue = $image->get_by_image_id($teng_r, $image_id);
    my $format = $queue->format;

    my $params = [
        {
            key => "${image_id}.${format}",
            bucket => $BUCKET,
            'copy-source' => "${TMP_BUCKET}/${image_name}.${format}",
        },
        {
            key => "${image_id}_thumb.${format}",
            bucket => $BUCKET,
            'copy-source' => "${TMP_BUCKET}/${image_name}_thumb.${format}",
        }
    ];

    for my $param (@{$params}) {
        my $res = $aws->s3api('copy-object', $param);
        if (!$res) {
            critf("$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}");
            next;
        } else {
            my $tmp_size;
            my $size;
            my $source_name = $1 if ($param->{'copy-source'} =~ m{^[^\s]+/([^\s]+)$});
            # list object of tmp
            my $res1 = $aws->s3api('list-objects', {prefix => $source_name, bucket => $TMP_BUCKET});
            if($res1) {
                $tmp_size = $res1->{Contents}[0]->{Size};
            } else {
                critf("$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}");
            }
            # list object
            my $res2 = $aws->s3api('list-objects', {prefix => $param->{key}, bucket => $BUCKET});
            if($res2) {
                $size = $res2->{Contents}[0]->{Size};
            } else {
                critf("$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}");
            }
            if($size != $tmp_size) {
                critf("size not match!");
                return;
            }
        }
    }
    infof("remove queue, id:$image_id, name:$image_name");
    $teng->txn_begin;
    my $ret = $image_queue->delete_queue_by_id($teng, $image_id);
    if ($ret) {
        $teng->txn_commit;
    } else {
        $teng->rollback;
    }
    return;
}


