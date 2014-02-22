package Babyry::Logic::Image;

use strict;
use warnings;

use utf8;
use Log::Minimal;

use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Image;

sub web_upload {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->web_upload($params);
}

sub web_submit {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->web_submit($params);
}

sub comment {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->comment($params);
}


1;

