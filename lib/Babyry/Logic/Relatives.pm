package Babyry::Logic::Relatives;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Relatives;

sub get {
    my ($self, $user_id) = @_;

    my $service = Babyry::Service::Relatives->new;

    return $service->get($user_id);
}

1;

