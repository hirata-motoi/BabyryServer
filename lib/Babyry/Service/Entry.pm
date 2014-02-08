package Babyry::Service::Entry;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Base/;
use Log::Minimal;

sub search {
    my ($self, $params) = @_;

    return { name => 'who' };
}

1;
