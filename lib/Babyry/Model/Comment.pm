package Babyry::Model::Comment;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub add {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'comment',
        {
            comment_id   => $params->{comment_id},
            image_id     => $params->{image_id},
            comment      => $params->{comment},
            created_at   => $params->{created_at},
            updated_at   => $params->{updated_at},
        }
    );

    return;
}


1;
