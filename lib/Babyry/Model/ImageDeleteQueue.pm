package Babyry::Model::ImageDeleteQueue;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub enqueue {
    my ($self, $teng, $image_id, $created_at) = @_;

    $created_at ||= time;

    $teng->insert(
        'image_delete_queue',
        {
            image_id   => $image_id,
            created_at => $created_at,
        }
    );
    return;
}

sub dequeue {
    my ($self, $teng, $opt) = @_;

    $opt ||= {};
    my @records = $teng->search(
        'image_delete_queue',
        {},
        $opt
    );

    my @ret = ();
    for my $record (@records) {
        push @ret, $record->get_columns;
    }
    return \@ret;
}

sub delete_queue_by_id {
    my ($self, $teng, $image_id) = @_;

    my $row = $teng->single(
        'image_delete_queue',
        { image_id => $image_id }
    ) or return;

    $row->delete;

    return $row->get_columns;
}


1;
