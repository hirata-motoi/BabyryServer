package Babyry::Model::PushToken;
use strict;
use warnings;
use utf8;

use parent qw/Babyry::Model::Base/;

sub set {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'push_token',
        {
            user_id => $params->{user_id},
            token   => $params->{arn},
        },
        'REPLACE'
    );

    return;
}

1;
