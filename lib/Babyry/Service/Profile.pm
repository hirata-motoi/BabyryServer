package Babyry::Service::Profile;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;

use Babyry::Model::UserChildMap;
use Log::Minimal;
use Data::Dump;


sub get {
    my ($self, $params) = @_;

    my $teng_r = $self->teng('BABYRY_MAIN_R');
    my $profile = {};

    # get user data
    my $user = $self->model('User')->get_by_user_id($teng_r, $params);
    $profile->{'user_id'} = $user->user_id;
    $profile->{'user_name'} = $user->user_name;
    $profile->{'has_icon'} = $user->has_icon;

    # get child data
    my $child_map_rows = $self->model('UserChildMap')->get_child_by_user_id($teng_r, $params);
    my $child_array = [];
    for my $row (@{$child_map_rows}) {
        my $child_hash = {};
        my $child = $self->model('Child')->get_by_child_id($teng_r, $row->child_id);
        $child_hash->{child_id} = $child->[0]->child_id;
        $child_hash->{child_name} = $child->[0]->child_name;
        $child_hash->{stamp_id} = $child->[0]->stamp_id;
        push @{$child_array}, $child_hash;
    }
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
    $self->model('UserChildMap')->add_child($teng, $params->{user_id}, $child_id, $unixtime);
    $self->model('Child')->add_child($teng, $child_id, $params->{child_name}, $params->{stamp_id});

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
    my $user_child_map = $self->model('UserChildMap')->delete_child($teng, $params);
    my $child = $self->model('Child')->delete_child($teng, $params);
    $teng->txn_commit;

    return {deleted => $params};
}

1;
