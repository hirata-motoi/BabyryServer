package Babyry::Model::Stamp;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Model::Base/;

sub get_by_id {
    my ($self, $teng, $stamp_id) = @_;

    my $row = $teng->single('stamp', { stamp_id => $stamp_id }) or return;
    $row->get_columns;
}

1;

