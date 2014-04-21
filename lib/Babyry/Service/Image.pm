package Babyry::Service::Image;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use Data::Dumper;
use List::MoreUtils qw/uniq/;
use Carp;

use Babyry::Model::TempImageUpload;
use Babyry::Model::Relatives;
use Babyry::Model::User;
use Babyry::Model::Sequence;
use Babyry::Model::Image;
use Babyry::Model::ImageUserMap;
use Babyry::Model::Comment;
use Babyry::Model::ImageQueue;
use Babyry::Model::Child;
use Babyry::Model::ImageChildMap;
use Babyry::Service::Entry;

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
    my @relatives_array_list = keys %$relatives;

    # TODO move to validator
    # verify済みユーザかのチェック
    croak sprintf('user_id:%d is not verified user', $params->{user_id})
        if !$user->is_verified($teng_r, $params);
    # 本当にrelatives関係なのかをチェック
    if ( my @not_relatives_users = grep { ! $relatives->{$_} } @{$params->{user}} ) {
        croak sprintf(
            'user_ids(shared users):%s is not relatives of user_id:%d',
            join(',', @not_relatives_users),
            $params->{user_id}
        );
    }

    # tmp image exist?
    #my $tmpdir  = Babyry::Common->config->{tmp_uploaded_image_dir};
    # TODO define config or %ENV
    #if ($tmpdir !~ m|^/|) {
    #    $tmpdir = File::Spec->catdir( Babyry->base_dir, $tmpdir );
    #}

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
    my $image_child_map = Babyry::Model::ImageChildMap->new();
    my $image_queue = Babyry::Model::ImageQueue->new();
    my $child = Babyry::Model::Child->new();
    my $unixtime = time();
    $teng->txn_begin;
    for my $img (@images) {
        my $id = $image_seq->get_id($teng, 'seq_image');
        if ($params->{is_icon}) {
            $user->update_icon_image( $teng,
                {
                    image_id => $id,
                    user_id  => $params->{'user_id'},
                }
            );
        }
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
        # is_icon : ユーザーのicon
        # child_id : こどものidがあった場合はimage_user_mapに入れない Entryに表示されないように
        if (!$params->{'is_icon'} && !$params->{'child_id'}) {
            for my $relative_id ( uniq( @{$params->{user}}, $params->{'user_id'} ) ) {
                $image_user_map->add($teng, {
                    image_id   => $id,
                    user_id    => $relative_id,
                    disabled   => 0,
                    created_at => $unixtime,
                    updated_at => $unixtime,
                });
            }
        }
        $image_queue->enqueue($teng,
            {
                image_name => $img,
                image_id   => $id,
                created_at => $unixtime,
            }
        );
        if ($params->{'child_id'}) {
            $child->add_icon($teng,
                {
                    updated_at => $unixtime,
                    icon_image_id => $id,
                    child_id => $params->{'child_id'},
                },
            );
        }
        for my $child_id (@{$params->{'child'}}) {
            $image_child_map->attach($teng, {
                image_id   => $id,
                child_id    => $child_id,
                created_at => $unixtime,
                updated_at => $unixtime,
            });
        }
    }
    $teng->txn_commit;

    # return json

    return;
}

# Service/Commentに切り出し
sub comment {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    my $teng_r = $self->teng('BABYRY_MAIN_R');

    # image_id check
    my $image = $self->model('image');
    my $res = $image->get_by_image_id($teng_r, $params->{'image_id'});
    return {error => 'NO_TARGET_IMAGE'} unless ($res->{row_data});
    # insert comment
    my $comment = $self->model('comment');
    my $comment_seq = $self->model('sequence');
    $teng->txn_begin;
    my $id = $comment_seq->get_id($teng, 'seq_comment');
    my $unixtime = time();
    $params->{'comment_id'} = $id;
    $params->{'created_at'} = $unixtime;
    $params->{'updated_at'} = $unixtime;
    my $ret = $comment->add($teng, $params);
    $teng->txn_commit;

    # TODO Babyry::Service::User::get_icon_urlsを使うように色々直す
    my $users = $self->model('user')->get_by_user_ids($teng, [ $ret->commented_by ]);
    # user_icon_url
    my $images = $self->model('image')->get_by_image_ids(
        $teng,
        [ map { $users->{$_}{icon_image_id} } keys %$users ]
    ) || {};

    return Babyry::Service::Entry::comment_info($ret, $users, $images);
}

sub child_attach {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');

    $teng->txn_begin;
    my $rows = $self->model('image_child_map')->attach($teng, {
        image_id => $params->{image_id},
        child_id => $params->{child_id},
    });
    $teng->txn_commit;

    return { rows => $rows };
}

sub child_detach {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');

    $teng->txn_begin;
    my $rows = $self->model('image_child_map')->detach($teng, {
        image_id => $params->{image_id},
        child_id => $params->{child_id},
    });
    $teng->txn_commit;

    return { rows => $rows };
}


1;

