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
    my ($self, $teng, $child_id, $params, $unixtime) = @_;
    my $birthday = $params->{'birth_year'} . '-' . $params->{'birth_month'} . '-' . $params->{'birth_day'};
    $teng->insert(
        'child',
        {  
            child_id  => $child_id,
            child_name  => $params->{'child_name'},
            birthday => $birthday,
            created_at => $unixtime,
            updated_at => $unixtime,
        }
    );
    return;
}

sub edit_child {
    my ($self, $teng, $params) = @_;
    my $birthday = $params->{'birth_year'} . '-' . $params->{'birth_month'} . '-' . $params->{'birth_day'};
    my $unixtime = time();
    $teng->update(
        'child',
        {  
            child_name => $params->{'child_name'},
            birthday => $birthday,
            updated_at => $unixtime,
        },
        {  
            child_id => $params->{'child_id'},
        }
    );
    return;
}

sub delete_child {
    my ($self, $teng, $params) = @_;

    #TODO
    # just set disable = 1
    my $row = $teng->single('child', { child_id => $params->{'child_id'} }) or return;
    $row->delete;

    return $row->get_columns;
}

sub add_icon {
    my ($self, $teng, $params) = @_;
    $teng->update(
        'child',
        {
            updated_at => $params->{'updated_at'},
            icon_image_id => $params->{'icon_image_id'},
        },
        {
            child_id => $params->{'child_id'},
        }
    );
    return;
}

1;

