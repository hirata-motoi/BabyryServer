package Babyry::Web::C::Stamp;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Web::C/;

use Babyry::Logic::Stamp;

sub attach {
    my ($self, $c, $p, $v) = @_;

    if ($v->has_error) {
        $v->set_error_message('stamp');
        return $c->render_json_validation_error($v);
    }

    my $image_id = $c->req->param('image_id');
    my $stamp_id = $c->req->param('stamp_id');

    my $logic = Babyry::Logic::Stamp->new;

    my $ret = eval {
        $logic->attach($image_id, $stamp_id);
    } || {};

    return $self->output_response_json($c, $ret, $@);
}

sub list {
    my ($self, $c, $p) = @_;

    my $logic = Babyry::Logic::Stamp->new;
    my $ret = eval {
        $logic->list( $c->stash->{user_id} );
    } || {};

    return $self->output_response_json($c, $ret, $@);
}

1;

