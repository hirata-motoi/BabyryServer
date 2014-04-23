package Babyry::Logic::Image;

use strict;
use warnings;

use utf8;
use Log::Minimal;

use parent qw/Babyry::Logic::Base/;

use Babyry::Service::Image;
use Babyry::Service::Wall;

sub web_upload {
    my ($self, $user_id) = @_;
    # TODO move to common class
    my $relatives = Babyry::Service::Wall->new->show($user_id);
    return $relatives;
}

sub web_upload_execute {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->web_upload_execute($params);
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

sub child_attach {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->child_attach($params);
}

sub child_detach {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->child_detach($params);
}


1;

