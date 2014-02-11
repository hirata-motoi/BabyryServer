package Babyry::Logic::Login;
use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Login;

sub execute {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Login->new;
    return $service->execute($params);
}

1;

