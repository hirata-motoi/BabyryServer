package Babyry::Model::WithdrawQueue;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub enqueue {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'withdraw_queue',
        {
            user_id   => $params->{user_id},
            created_at => $params->{unixtime},
        }
    );
    return;
}

sub dequeue {
    my ($self, $teng) = @_;

    my $sql = "SELECT * FROM withdraw_queue;";
    my @records =$teng->search_by_sql($sql);

    return \@records;
}

sub delete_queue_by_id {
    my ($self, $teng, $user_id) = @_;

    my $row = $teng->single('withdraw_queue', { user_id => $user_id }) or return 0;
    $row->delete;

    return $row->get_columns;
}


1;
