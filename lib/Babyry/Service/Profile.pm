package Babyry::Service::Profile;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;

use Log::Minimal;
use Data::Dumper;


sub get {
    my ($self, $params) = @_;

    my $teng_r = $self->teng('BABYRY_MAIN_R');
    my $profile = {};

    # get user data
    my $user = $self->model('User')->get_by_user_id($teng_r, {user_id => $params->{target_user_id}});
    $profile->{'user_id'} = $user->user_id;
    $profile->{'accessed_user_id'} = $params->{user_id};
    $profile->{'user_name'} = $user->user_name;
    $profile->{'icon_image_id'} = $user->icon_image_id;

    # get icon image
    my $image = $self->model('Image')->get_by_image_id($teng_r, $profile->{'icon_image_id'});
    if ($image) {
        $profile->{'icon_image_url'} = $image->url;
    } else {
        $profile->{'icon_image_url'} = "";
    }

    # get relatives
    my $relatives = $self->model('Relatives')->get_by_user_id($teng_r, $profile->{'user_id'});
    my $child = $self->model('Child')->new();
    my $relatives_array = [];
    my $child_array = [];
    for my $relative_id ( keys %{$relatives}, $profile->{'user_id'} ) {
        # 自分(user_id)のrelativesの情報をとるときには、user_id(自分)のときはskip
        if ($relative_id != $profile->{'user_id'}) {
            # name
            my $relative_info = $self->model('User')->get_by_user_id($teng_r, {user_id => $relative_id});
            $relatives->{$relative_id}->{relative_name} = $relative_info->user_name;

            # image
            my $relative_image = $self->model('Image')->get_by_image_id($teng_r, $relative_info->icon_image_id);
            if ($relative_image) {
                $relatives->{$relative_id}->{relative_icon_url} = $relative_image->url;
            } else {
                $relatives->{$relative_id}->{relative_icon_url} = "";
            }
            # basic info
            push @{$relatives_array}, $relatives->{$relative_id};
        }

        # get child of each relatives
        my $_child_array = $child->get_by_created_by($teng_r, $relative_id);
        for my $_child (@{$_child_array}) {
            my $child_hash = {};
            $child_hash->{child_id} = $_child->child_id;
            $child_hash->{child_name} = $_child->child_name;
            $child_hash->{created_by} = $_child->created_by;
            if ($_child->birthday =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/) {
                $child_hash->{child_birthday_year} = $1;
                $child_hash->{child_birthday_month} = $2;
                $child_hash->{child_birthday_day} = $3;
            }
            my $child_image = $self->model('Image')->get_by_image_id($teng_r, $_child->icon_image_id);
            if ($child_image) {
                $child_hash->{child_icon_url} = $child_image->url;
            } else {
                $child_hash->{child_icon_url} = "";
            }
            push @{$child_array}, $child_hash;
        }
    }
    $profile->{'relatives'} = $relatives_array;
    $profile->{'child'} = $child_array;

    return $profile;
}

sub edit_name {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    my $ret = $self->model('User')->update_by_user_id($teng, $params->{'user_id'}, { user_name => $params->{'user_name'}});
    $teng->txn_commit;

    return $ret;
}

sub add_child {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    my $unixtime = time();
    $teng->txn_begin;

    # get child sequence
    my $child_id = $self->model('Sequence')->get_id($teng, 'seq_child');

    # insert child data
    $self->model('Child')->add_child($teng, $child_id, $params, $unixtime);

    $teng->txn_commit;

    return {id => $child_id};
}

sub edit_child {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    my $child = $self->model('Child')->edit_child($teng, $params);
    $teng->txn_commit;

    return {updated => $params};
}

sub delete_child {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    my $child = $self->model('Child')->delete_child($teng, $params);
    $teng->txn_commit;

    return {deleted => $params};
}

1;
