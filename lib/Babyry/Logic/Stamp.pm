package Babyry::Logic::Stamp;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Stamp;

sub attach {
    my ($self, $image_id, $stamp_id) = @_;

    my $service = Babyry::Service::Stamp->new;

    return $service->attach($image_id, $stamp_id);
}

sub detach {
    my ($self, $image_id, $stamp_id) = @_;

    my $service = Babyry::Service::Stamp->new;

    return $service->detach($image_id, $stamp_id);
}

sub list {
    my ($self, $user_id) = @_;

    my $service = Babyry::Service::Stamp->new;

    return $service->list($user_id);
}

1;

