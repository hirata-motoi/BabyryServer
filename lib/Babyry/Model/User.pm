package Babyry::Model::User;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Base/;

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
            user_id     => $params->{user_id},
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

1;

