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
use Babyry::Model::ImageUserMap;
use Babyry::Model::Comment;

sub web_upload_execute {
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
    my $tmpdir  = Babyry::Common->config->{tmp_uploaded_image_dir};
    # TODO define config or %ENV
    if ($tmpdir !~ m|^/|) {
        $tmpdir = File::Spec->catdir( Babyry->base_dir, $tmpdir );
    }

    my @images;
    for my $img (@{$params->{image}}) {
        return {error => 'INVALID FORMAT'} unless ($img =~ /^(.+)_thumb.(jpg|jpeg|png)$/);
        my ($img_name, $format) = ($1, $2);
        push @images, $img_name;
        return {error => 'NO TMP IMAGE'} unless (-f "$tmpdir/$img" and -f "$tmpdir/$img_name.$format");
    }

    # get image_id insert database, then mv to upload dir
    my $image_seq = Babyry::Model::Sequence->new();
    my $image = Babyry::Model::Image->new();
    my $image_user_map = Babyry::Model::ImageUserMap->new();
    my $unixtime = time();
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
        for my $relative_id (@relatives_array_list, $params->{'user_id'}) {
            $image_user_map->add($teng, {
                image_id   => $id,
                user_id    => $relative_id,
                disabled   => 0,
                created_at => $unixtime,
                updated_at => $unixtime,
            });
        }
        system("touch /data/image/uploaded/${id}_${img}");
    }
    $teng->txn_commit;

    # return json

    return;
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

