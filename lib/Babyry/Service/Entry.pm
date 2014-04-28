package Babyry::Service::Entry;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use List::MoreUtils qw/uniq/;
use Data::Dump;

use Babyry::Model::Image;
use Babyry::Model::ImageUserMap;
use Babyry::Model::ImageStampMap;
use Babyry::Model::Comment;
use Babyry::Common;
use Babyry::Service::Child;

#params
# stamp_id:    int(default: [])
# uploaded_by: int(default: 0)
# count:       int(default: 10)
# page:        int(default: 1)
# searchの条件は今後増えるかもしれないので、search自体は、dispatchするだけにする。
sub search {
    my ($self, $params) = @_;
    my ($stamp_id, $child_id, $uploaded_by, $count, $page, $offset, $user_id)
        = @$params{qw/stamp_id child_id uploaded_by count page offset user_id/};

    my $teng = $self->teng('BABYRY_MAIN_R');
    my $from = defined $offset ? $offset : ($page - 1) * $count || 0;

    my ($images, $found_row_count)  = Babyry::Model::ImageUserMap::get_by_user_id_stamp_id_child_id($teng, $uploaded_by, $stamp_id, $child_id, $from, $count);

    # imagesを他の経路から取ってきたときも、get_entries_by_imagesを使い回せる用にしておく。
    my $entries = $self->get_entries_by_images($images);
    return {
        entries          => $entries,
        found_row_count  => $found_row_count,
        related_child    => Babyry::Service::Child->new->get_related_child_list($user_id),
    };
}

sub get_entries_by_images {
    my ($self, $images) = @_;
    my $teng = $self->teng('BABYRY_MAIN_R');

    my $image_ids   = Babyry::Model::Image::get_image_ids_by_rows($images);
    my $child_info  = $self->get_child_info($images) || {};
    
    my @entries;

    for my $image (@$images) {
        my $columns = $image->get_columns;

        # temporary url
        my $url = $self->get_url_by_image_id($image->image_id);

        # comments
        my $comments = Babyry::Model::Comment::get_by_image_id($teng, $image->image_id, 0, 10);

        # user_name & user_icon_url
        my @uniq_user_ids = uniq( map { $_->commented_by } @{$comments} );
        my $users = $self->model('user')->get_by_user_ids($teng, \@uniq_user_ids);

        # user_icon_url
        my $images = $self->model('image')->get_by_image_ids(
            $teng,
            [ map { $users->{$_}{icon_image_id} } keys %$users ]
        ) || {};

        my @cmt_array = map { comment_info($_, $users, $images) } @$comments;

        push @entries, {
            %$columns,
            stamps             => [],
            child              => $child_info->{ $image->image_id },
            comments           => \@cmt_array,
            fullsize_image_url => $url,
        };
    }
    
    return \@entries;
}

sub comment_info {
    my ($cmt, $users, $images) = @_;

    my $commented_by  = $cmt->commented_by;
    return +{
        comment_id            => $cmt->comment_id,
        image_id              => $cmt->image_id,
        comment               => $cmt->comment,
        created_at            => $cmt->created_at,
        user_id               => $commented_by,
        commented_by_name     => $users->{$commented_by}{user_name},
        commented_by_icon_url => _get_user_icon_url($commented_by, $users, $images),
    };
}

sub _get_user_icon_url {
    my ($user_id, $users, $images) = @_;

    my $default_user_icon_url = Babyry::Common->config->{default_user_icon_url};

    my $icon_url = eval {
        my $icon_image_id = $users->{$user_id}{icon_image_id} or die;
        my $icon_image    = $images->{$icon_image_id} or die;
        $icon_image->{url} or die;
    };
    return $default_user_icon_url if $@;
    $icon_url;
}

sub get_url_by_image_id {
    my ($self, $id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');
    my $url = Babyry::Model::Image->new()->get_by_image_id($teng, $id);

    return $url->url;
}

sub get_child_info {
    my ($self, $images) = @_;

    return unless $images && ref $images eq 'ARRAY' && scalar @$images;

    my @image_ids = map { $_->image_id } @$images;

    return Babyry::Service::Child->new->get_child_info_by_image_ids(\@image_ids);
}

1;
