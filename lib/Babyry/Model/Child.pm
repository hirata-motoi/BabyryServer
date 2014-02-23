package Babyry::Model::Child;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Model::Base/;

sub get_by_child_id {
    my ($self, $teng, $child_id) = @_;

    my $sql = <<SQL;
        SELECT * from child where child_id = ?
SQL
    my @records = $teng->search_by_sql(
        $sql,
        [$child_id]
    );

    return \@records; 
}

sub add_child {
    my ($self, $teng, $child_id, $child_name, $stamp_id) = @_;

    $teng->insert(
        'child',
        {  
            child_id  => $child_id,
            child_name  => $child_name,
            stamp_id  => $stamp_id,
        }
    );
    return;
}

sub edit_child {
    my ($self, $teng, $params) = @_;
    $teng->update(
        'child',
        {  
            child_name => $params->{'child_name'},
            stamp_id => $params->{'stamp_id'},
        },
        {  
            child_id => $params->{'child_id'},
        }
    );
    return;
}

sub delete_child {
    my ($self, $teng, $params) = @_;

    my $row = $teng->single('child', { child_id => $params->{'child_id'} }) or return;
    $row->delete;

    return $row->get_columns;
}


1;

