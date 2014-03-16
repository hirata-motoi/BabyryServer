package Babyry::Web::C::Relatives;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Web::C/;

use Babyry::Logic::Relatives;

sub index {
    my ($self, $c, $p, $v) = @_;

    return $self->output_response($c, '/relatives/index.tx', {}, $@);
}

sub search {
    my ($self, $c, $p, $v) = @_;

    my $user_id = $c->stash->{user_id};
    my $str     = $c->req->param('str');
    my $res  = eval {
        Babyry::Logic::Relatives->new->search_by_name($user_id, $str);
    } || {};
    return $self->output_response_json($c, { %$res }, $@);
}

sub list {
    my ($self, $c, $p, $v) = @_;

    my $user_id = $c->stash->{user_id};
    my $relatives = eval {
        Babyry::Logic::Relatives->new->get($user_id)
    } || {};

    return $self->output_response_json($c, { %$relatives }, $@);
}

sub apply {
    my ($self, $c, $p, $v) = @_;

    my $user_id     = $c->stash->{user_id};
    my $relative_id = $c->req->param('user_id');
    my $res = eval {
        Babyry::Logic::Relatives->new->apply($user_id, $relative_id);
    } || {};
    return $self->output_response_json($c, { %$res }, $@);
}

sub admit {
    my ($self, $c, $p, $v) = @_;

    my $user_id     = $c->stash->{user_id};
    my $relative_id = $c->req->param('user_id');
    my $res = eval {
        Babyry::Logic::Relatives->new->admit($user_id, $relative_id);
    } || {};
    return $self->output_response_json($c, { %$res }, $@);
}

1;

