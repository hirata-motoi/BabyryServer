package Babyry::Service::Image;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use Data::Dumper;

use Babyry::Model::TempImageUpload;
use Babyry::Model::Relatives;
use Babyry::Model::User;
use Babyry::Model::Sequence;
use Babyry::Model::Image;
use Babyry::Model::Comment;

sub web_upload {
    my ($self, $params) = @_;

    # make thumbnail
    my $model = Babyry::Model::TempImageUpload->new;
    my $ret = $model->make_thumbnail($params);

    return $ret;
}

sub web_submit {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    my $teng_r = $self->teng('BABYRY_MAIN_R');

    # relatives exist and verified?
    my $relatives = Babyry::Model::Relatives->new()->get_by_user_id($teng_r, $params->{'user_id'});
    my $user = Babyry::Model::User->new();
    my @relatives_array_list;
    for my $rel (keys %{$relatives}) {
        push @relatives_array_list, $relatives->{$rel}->{relative_id};
    }
    my $relatives_list = join('|', @relatives_array_list);
    for my $share_id (@{$params->{user}}) {
        return {error => 'NOT RELATIVES'} if ($share_id !~ /^($relatives_list)$/ or !$user->is_verified($teng_r, $params));
    }

    # post auth ok? (??TODO??)

    # tmp image exist?
    my $tmp_dir = '/var/www/html/tmp_uploaded_image';
    my @images;
    for my $img (@{$params->{image}}) {
        return {error => 'INVALID FORMAT'} unless ($img =~ /^(.+)_thumb.jpg$/);
        my $img_name = $1;
        push @images, $img_name;
        return {error => 'NO TMP IMAGE'} unless (-f "$tmp_dir/$img" and -f "$tmp_dir/$img_name.jpg");
    }

    # get image_id insert database, then mv to upload dir
    my $image_seq = Babyry::Model::Sequence->new();
    my $image = Babyry::Model::Image->new();
    my $unixtime = time();
    my $image_url = [];
    $teng->txn_begin;
    for my $img (@images) {
        my $id = $image_seq->get_id($teng, 'seq_image');
        $image->set_new_image( $teng,
            {
                image_id     => $id,
                uploaded_by  => $params->{'user_id'},
                created_at   => $unixtime,
                updated_at   => $unixtime, 
            }
        );
        push @{$image_url}, "http://babyryserver5001/tmp_uploaded_image/$img.jpg"
    }
    $teng->txn_commit;

    # return json

    return {url => $image_url};
}

sub comment {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    my $teng_r = $self->teng('BABYRY_MAIN_R');

    # image_id check
    my $image = Babyry::Model::Image->new();
    my $res = $image->get_by_image_id($teng_r, $params->{'image_id'});
    return {error => 'NO_TARGET_IMAGE'} unless ($res->{row_data});
    # insert comment
    my $comment = Babyry::Model::Comment->new();
    my $comment_seq = Babyry::Model::Sequence->new();
    $teng->txn_begin;
    my $id = $comment_seq->get_id($teng, 'seq_comment');
    my $unixtime = time();
    $params->{'comment_id'} = $id;
    $params->{'created_at'} = $unixtime;
    $params->{'updated_at'} = $unixtime;
    $comment->add($teng, $params);
    $teng->txn_commit;

    return;
}


1;

