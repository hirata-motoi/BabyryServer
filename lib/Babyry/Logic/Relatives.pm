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

sub search_by_name {
    my ($self, $user_id, $str) = @_;

    my $service = Babyry::Service::Relatives->new;

    return $service->search_by_name($user_id, $str);
}

sub apply {
    my ($self, $user_id, $relative_id) = @_;

    my $service = Babyry::Service::Relatives->new;

    return $service->apply($user_id, $relative_id);
}

sub admit {
    my ($self, $user_id, $relative_id) = @_;

    my $service = Babyry::Service::Relatives->new;

    return $service->admit($user_id, $relative_id);
}

sub cancel {
    my ($self, $user_id, $relative_id) = @_;

    my $service = Babyry::Service::Relatives->new;

    return $service->cancel($user_id, $relative_id);
}

sub reject {
    my ($self, $user_id, $relative_id) = @_;

    my $service = Babyry::Service::Relatives->new;

    return $service->reject($user_id, $relative_id);
}

1;

