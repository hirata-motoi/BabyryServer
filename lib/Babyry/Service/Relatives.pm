package Babyry::Service::Relatives;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use Babyry::Service::User;

use constant {
    RELATIVE_STATUS_UNADMITTED => 0,
    RELATIVE_STATUS_ADMITTED   => 1,
};

sub get {
    my ($self, $user_id) = @_;

    my $teng      = $self->teng('BABYRY_MAIN_R');
    my $relatives = $self->model('relatives')->get_by_user_id($teng, $user_id);
    my $user      = $self->model('user')->get_by_user_ids($teng, [ keys %$relatives ]);
    my $icon_urls = Babyry::Service::User->new->get_icon_urls({ user_info_list => $user });

    my %relatives_info = ();
    for my $relative_id ( keys %$relatives ) {

        my $relation = $relatives->{$relative_id}{relative_relation} || '';
        $relatives_info{$relation} ||= {};

        $relatives_info{$relation}{$relative_id} = {
            %{ $relatives->{$relative_id} },
            icon_url  => $icon_urls->{$relative_id},
            user_name => $user->{$relative_id}{user_name},
        }
    }
    return { relatives => \%relatives_info };
}

sub search_by_name {
    my ($self, $user_id, $str) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');

    my $matched_users = $self->model('user')->search_by_name($teng, $str);
    my $relatives     = $self->model('relatives')->get_by_user_id($teng, $user_id) || {};
    my $icon_urls     = Babyry::Service::User->new->get_icon_urls({
        user_info_list => $matched_users
    });

    my @search_result = ();
    for my $matched_user_id ( keys %$matched_users ) {

        # 自分自身は除外
        next if $matched_user_id == $user_id;

        # 承認されたrelativesは除外する
        my $relative = $relatives->{ $matched_user_id };
        next if $relative && $relative->{relative_relation} eq 'approved';

        # relative_statusをmerge
        push @search_result, {
            %{$matched_users->{$matched_user_id}},
            icon_url          => $icon_urls->{ $matched_user_id },
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

sub cancel {
    my ($self, $user_id, $relative_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    $self->model('relatives')->cancel(
        $teng,
        $user_id,
        {
            user_id => $relative_id
        }
    );
    $teng->txn_commit;
}

sub reject {
    my ($self, $user_id, $relative_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    $self->model('relatives')->reject(
        $teng,
        $user_id,
        {
            user_id => $relative_id
        }
    );
    $teng->txn_commit;
}

1;

