package Babyry::Web::C::Relatives;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Web::C/;

use Babyry::Logic::Relatives;

sub index {
    my ($self, $c, $p, $v) = @_;

    my $user_id = $c->stash->{user_id};
    my $relatives = eval {
        Babyry::Logic::Relatives->new->get($user_id)
    } || {};

    return $self->output_response($c, '/relatives/index.tx', { %$relatives }, $@);
}


1;

