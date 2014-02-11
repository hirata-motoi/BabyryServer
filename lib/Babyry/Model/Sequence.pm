package Babyry::Model::Sequence;
use strict;
use warnings;
use utf8;

use parent qw/Babyry::Model::Base/;

sub get_id {
    my ($self, $teng, $table) = @_;

    $teng->do("UPDATE $table SET id=LAST_INSERT_ID(id+1)");
    my $row = $teng->dbh->selectall_hashref("SELECT LAST_INSERT_ID() AS id", 'id', undef);
    return $row->{id};
}

1;

