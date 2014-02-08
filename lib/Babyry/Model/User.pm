package Babyry::Model::User;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Base/;

use Log::Minimal;

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

sub get_status {
    my ($self, $teng, $params) = @_;

    my $res = $teng->single(
        'user',
        {
            user_id     => $params->{user_id},
        }
    );

    return $res->user_status;
}

sub update_status {
    my ($self, $teng, $params) = @_;

    my $res = $teng->update(
        'user' => {
            user_status => $params->{status},
        }, {
            user_id => $params->{user_id},
        },
    );
    if (!$res) {
        return {error => 'UPDATE_FAILED'};
    }
    return; 
}

1;

