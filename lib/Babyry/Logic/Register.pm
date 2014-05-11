package Babyry::Logic::Register;
use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Register;

sub execute {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Register->new;
    return $service->execute($params);
}

=pot
sub verify {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Register->new;
    return $service->verify($params);
}
=cut

sub activate {
    my ($self, $params) = @_;
    my $service = Babyry::Service::Register->new;
    return $service->activate($params);
}

sub devicetoken {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Register->new;
    return $service->devicetoken($params);
}

sub is_verified {
    my ($self, $user_id) = @_;

    return Babyry::Service::Register->new->is_verified($user_id);
}

sub withdraw_execute {
    my ($self, $params) = @_;

    return Babyry::Service::Register->new->withdraw_execute($params);
}

1;

