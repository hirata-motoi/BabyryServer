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
use Babyry::Model::ImageQueue;

sub is_valid_image_id {
   my ($self, $image_id) = @_;
   my $model = $self->model('image');
   my $teng  = $self->teng('BABYRY_MAIN_R');

   return $model->get_by_image_id($teng, $image_id) ? 1 : 0;
}

sub has_authorization {
    my ($self, $user_id, $image_id) = @_;

    return ( grep { $image_id == $_ } @{ $self->get_authorized_image_ids($user_id) } )
        ? 1 : 0;
}

sub get_authorized_image_ids {
   my ($self, $user_id) = @_;
   my $model = $self->model('image_user_map');
   my $teng  = $self->teng('BABYRY_MAIN_R');

   return $model->get_image_ids_by_user_id($teng, $user_id);
}

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

    # tmp image exist?
    my $tmpdir  = Babyry::Common->config->{tmp_uploaded_image_dir};
    # TODO define config or %ENV
    if ($tmpdir !~ m|^/|) {
        $tmpdir = File::Spec->catdir( Babyry->base_dir, $tmpdir );
    }

    my %format;
    my @images;
    for my $img (@{$params->{image}}) {
        return {error => 'INVALID FORMAT'} unless ($img =~ /^(.+)_thumb.(jpg|jpeg|png)$/);
        my ($img_name, $format) = ($1, $2);
        push @images, $img_name;
        $format{$img_name} = $format;
    }

    # get image_id insert database, then mv to upload dir
    my $image_seq = Babyry::Model::Sequence->new();
    my $image = Babyry::Model::Image->new();
    my $image_user_map = Babyry::Model::ImageUserMap->new();
    my $image_queue = Babyry::Model::ImageQueue->new();
    my $unixtime = time();
    $teng->txn_begin;
    for my $img (@images) {
        my $id = $image_seq->get_id($teng, 'seq_image');
        my $_format = $format{$img};
        $image->set_new_image( $teng,
            {
                image_id     => $id,
                uploaded_by  => $params->{'user_id'},
                created_at   => $unixtime,
                updated_at   => $unixtime,
                format       => $_format,
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
        $image_queue->enqueue($teng,
            {
                image_name => $img,
                image_id   => $id,
                created_at => $unixtime,
            }
        );
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

