package Babyry::Model::WithdrawComment;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Model::Base/;
use Carp;

use Log::Minimal;


sub create {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'withdraw_comment',
        {
            user_id     => $params->{user_id},
            comment     => $params->{withdraw_comment},
            created_at  => $params->{unixtime},
        }
    );
}

1;
