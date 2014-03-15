package Babyry::Web::C::Relatives;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Web::C/;

use Babyry::Logic::Stamp;

sub index {
    my ($self, $c, $p, $v) = @_;

    return $self->output_response($c, '/relatives/index.tx', {});
}


1;

