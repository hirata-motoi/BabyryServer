package Babyry::Model::ImageQueue;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub enqueue {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'image_queue',
        {
            image_name => $params->{image_name},
            image_id   => $params->{image_id},
            created_at => $params->{created_at},
        }
    );
    return;
}

sub dequeue {
    my ($self, $teng) = @_;

    my $sql = "SELECT * FROM image_queue;";
    my @records =$teng->search_by_sql($sql);

    return \@records;
}

sub delete_queue_by_id {
    my ($self, $teng, $image_id) = @_;

    my $row = $teng->single('image_queue', { image_id => $image_id }) or return 0;
    $row->delete;

    return $row->get_columns;
}


1;
