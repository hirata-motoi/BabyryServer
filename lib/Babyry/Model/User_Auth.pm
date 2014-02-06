package Babyry::Model::User_Auth;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Base/;
use Log::Minimal;

sub create {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'user_auth',
        {
            user_id     => $params->{user_id},
            email        => $params->{email},
            password_hash  => $params->{password_hash},
            created_at => $params->{created_at},
            updated_at => $params->{updated_at},
        }
    );
}

sub login {
    my ($self, $teng, $params) = @_;

    my $res = $teng->single(
        'user_auth',
        { 
            email => $params->{email},
            password_hash => $params->{enc_pass},
        }
    );
    my $user_id = $res->user_id;

    return $user_id;
}

1;

