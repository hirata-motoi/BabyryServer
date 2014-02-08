package Babyry::Logic::Entry;
use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic/;

use Babyry::Service::Entry;

sub search {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Entry->new;
    return $service->search($params);
}

1;

