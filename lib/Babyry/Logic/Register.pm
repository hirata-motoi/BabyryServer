package Babyry::Logic::Register;
use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic/;

use Babyry::Service::Register;

sub execute {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Register->new;
    return $service->execute($params);
}

sub verify {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Register->new;
    return $service->verify($params);
}

1;

