package Babyry::Model::UserChildMap;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Model::Base/;

use Log::Minimal;

sub get_child_by_user_id {
    my ($self, $teng, $params) = @_;

    my $sql = <<SQL;
        SELECT child_id from user_child_map where user_id = ?
SQL
    my @records = $teng->search_by_sql(
        $sql,
        [$params->{user_id}]
    );

    return \@records;
}

sub get_child_by_user_ids {
    my ($teng, $user_ids) = @_;

    return unless $user_ids && scalar @$user_ids;

    my @records = $teng->search(
        'user_child_map',
        {
            user_id => $user_ids
        }
    );
    return \@records;
}

sub add_child {
    my ($self, $teng, $user_id, $child_id, $unixtime) = @_;

    $teng->insert(
        'user_child_map',
        {  
            user_id   => $user_id,
            child_id  => $child_id,
            created_at => $unixtime,
            updated_at => $unixtime,
        }
    );
    return;
}

sub delete_child {
    my ($self, $teng, $params) = @_;
   
    my $row = $teng->single('user_child_map', {
        user_id => $params->{'user_id'},
        child_id => $params->{'child_id'},
    }) or return;
    $row->delete;

    return $row->get_columns;
}


1;

