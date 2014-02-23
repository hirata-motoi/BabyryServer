package Babyry::Logic::Profile;
use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Profile;

sub get {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Profile->new;
    return $service->get($params);
}

sub edit_name {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Profile->new;
    return $service->edit_name($params);
}

sub add_child {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Profile->new;
    return $service->add_child($params);
}

sub edit_child {
    my ($self, $params) = @_;
   
    my $service = Babyry::Service::Profile->new;
    return $service->edit_child($params);
}

sub delete_child {
    my ($self, $params) = @_;
   
    my $service = Babyry::Service::Profile->new;
    return $service->delete_child($params);
}

1;
