package Babyry::Web::C::Menu;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Invite;

sub index {
    my ($self, $c) = @_;

    return $c->render('menu/index.tx', {});
}

sub faq {
    my ($self, $c) = @_;

    return $c->render('menu/faq.tx', {});
}

1;

