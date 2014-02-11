package Babyry::Logic::Wall;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Logic::Base/;
use Babyry::Service::Wall;

sub show {
    my ($self, $user_id) = @_;

    return Babyry::Service::Wall->new->show($user_id);
}

1;

