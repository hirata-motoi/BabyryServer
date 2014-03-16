package Babyry::Service::Relatives;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;

use constant {
    RELATIVE_STATUS_UNADMITTED => 0,
    RELATIVE_STATUS_ADMITTED   => 1,
};

sub get {
    my ($self, $user_id) = @_;

    my $teng      = $self->teng('BABYRY_MAIN_R');
    my $relatives = $self->model('Relatives')->get_by_user_id($teng, $user_id);
    my $user      = $self->model('UserAuth')->get_by_ids( $teng, [ keys %$relatives ] );

    my %relatives_info = ();
    for my $relative_id ( keys %$relatives ) {
        # 成立していないものは除外
        next if $relatives->{$relative_id}{relative_relation} ne 'approved';

        $relatives_info{$relative_id} = {
            %{ $relatives->{$relative_id} },
            email => $user->{$relative_id}{email},
        }
    }
    return { relatives => \%relatives_info };
}

sub search_by_name {
    my ($self, $user_id, $str) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');

    my $matched_users = $self->model('user')->search_by_name($teng, $str);
    my $relatives = $self->model('relatives')->get_by_user_id($teng, $user_id) || {};

    my @search_result = ();
    for my $user ( @{ $matched_users->{users} } ) {

        # 承認されたrelativesは除外する
        my $relative = $relatives->{ $user->{user_id} };
        next if $relative && $relative->{relative_relation} eq 'approved';

        # relative_statusをmerge
        push @search_result, {
            %$user,
            relative_relation => $relative->{relative_relation}
        };
    }
    return { users => \@search_result };
}

sub apply {
    my ($self, $user_id, $relative_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    $self->model('relatives')->request(
        $teng,
        {
            user_id     => $user_id,
            relative_id => $relative_id
        }
    );
    $teng->txn_commit;
}

sub admit {
    my ($self, $user_id, $relative_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    $self->model('relatives')->admit(
        $teng,
        $user_id,
        {
            user_id => $relative_id
        }
    );
    $teng->txn_commit;
}

1;

