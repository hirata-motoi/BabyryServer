package Babyry::Logic::Album;
use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Album;

sub search {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Album->new;
    return $service->search($params);
}

sub add_attr {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Album->new;
    return $service->add_attr($params);
}

sub edit_name {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Album->new;
    return $service->edit_name($params);
}

sub delete_attr {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Album->new;
    return $service->delete_attr($params);
}

1;
