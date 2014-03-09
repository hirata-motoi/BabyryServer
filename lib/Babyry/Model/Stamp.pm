package Babyry::Model::Stamp;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Model::Base/;
use Babyry::Common;

sub get_by_id {
    my ($self, $teng, $stamp_id) = @_;

    my $row = $teng->single('stamp', { stamp_id => $stamp_id }) or return;
    $row->get_columns;
}

sub get_details_by_ids {
    my ($self, $teng, $stamp_ids) = @_;

    my $itr = $teng->search(
        'stamp',
        {
            stamp_id => $stamp_ids
        }
    );

    my $icon_url_base = Babyry::Common->config->{icon_url_base};
    my @stamps = ();
    while ( my $r = $itr->next ) {
        push @stamps, {
            stamp_id    => $r->stamp_id,
            stamp_name  => $r->stamp_name,
            icon_url    => sprintf($icon_url_base, $r->stamp_id),
        };
    }

    return \@stamps;
}

sub get {
    my ($self, $teng) = @_;

    my @stamps = ();

    my $itr = $teng->search('stamp');
    while (my $row = $itr->next) {
        push @stamps, $row->get_columns;
    }

    return \@stamps;
}

1;

