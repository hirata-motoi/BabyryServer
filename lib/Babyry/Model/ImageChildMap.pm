package Babyry::Model::ImageChildMap;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub add{
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'image_child_map',
        {
            image_id   => $params->{image_id},
            child_id    => $params->{child_id},
            disabled   => $params->{disabled},
            created_at => $params->{created_at},
            updated_at => $params->{updated_at},
        }
    );
    return;
}

1;
