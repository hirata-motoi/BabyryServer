package Babyry::Model::RegisterToken;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Base/;


sub create {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'register_token',
        {
            user_id     => $params->{user_id},
            token       => $params->{token},
            expired_at  => $params->{expired_at},
        }
    );
}

sub verify {
    my ($self, $teng, $token) = @_;

    my $row = $teng->single('register_token', { token => $token });
    $row->delete;

    return $row ? $row->get_columns : undef;
}

1;

