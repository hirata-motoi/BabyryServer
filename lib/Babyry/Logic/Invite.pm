package Babyry::Logic::Invite;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic::Base/;

use  Babyry::Service::Invite;
use Log::Minimal;

sub execute {
    my ($self, $params) = @_;
    
    my $service = Babyry::Service::Invite->new;
    return $service->execute($params);
}

1;

