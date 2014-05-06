package Babyry::Model::ActivateKey;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Model::Base/;


sub create {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'activate_key',
        {
            user_id     => $params->{user_id},
            key         => $params->{key},
            expired_at  => $params->{expired_at},
        }
    );
}

sub delete {
    my ($self, $teng, $params) = @_;

    my $row = $teng->single(
        'activate_key',
        {
            user_id => $params->{user_id},
            key => $params->{key}
        }
    ) or return;
    $row->delete;

    return $row->get_columns;
}


1;

