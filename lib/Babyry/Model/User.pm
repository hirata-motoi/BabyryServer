package Babyry::Model::User;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Model::Base/;
use Carp;

use Log::Minimal;

use constant {
    IS_VERIFIED => 1,
};

sub create {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'user',
        {
            user_id     => $params->{user_id},
            created_at  => $params->{created_at},
            updated_at  => $params->{updated_at},
        }
    );
}

sub is_verified {
    my ($self, $teng, $params) = @_;

    my $res = $teng->single(
        'user',
        {
            user_id => $params->{user_id},
        }
    );
    return $res->is_verified;
}

sub update_to_verified {
    my ($self, $teng, $params) = @_;

    return $teng->update(
        'user',
        {
            is_verified => IS_VERIFIED,
        },
        {
            user_id => $params->{user_id},
        },
    );
}

sub get_by_user_id {
    my ($self, $teng, $params) = @_;

    my $res = $teng->single(
        'user',
        {
            user_id => $params->{user_id},
        }
    );
    return $res;
}

sub update_by_user_id {
    my ($self, $teng, $user_id, $params) = @_;

    my $res = $teng->update(
        'user',
        $params,
        {
            user_id => $user_id,
        },
    );
    return {user_id =>$user_id, params => $params};
}

sub search_by_name {
    my ($self, $teng, $str) = @_;

    croak "invalid search string: $str" if ! $str;

    my $itr = $teng->search(
        'user',
        {
            user_name => {
                'like' => '%' . $self->escape4like($str) . '%'
            },
            is_verified => 1,
            disabled    => 0,
        }
    );

    my @users = ();
    while ( my $u = $itr->next ) {
        push @users, {
            user_id   => $u->user_id,
            user_name => $u->user_name,
        };
    }
    return { users => \@users };
}

1;

