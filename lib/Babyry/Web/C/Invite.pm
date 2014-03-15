package Babyry::Web::C::Invite;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Invite;

sub index {
    my ($self, $c) = @_;

    return $c->render('invite/index.tx', {});
}

sub execute {
    my ($self, $c) = @_;

    # TODO move to validator
    return $c->render_500() if ! $c->stash->{user_id};

    my $params = {
        user_id       => $c->stash->{user_id},
        invite_method => $c->req->param('invite_method'),
    };
    my $logic = Babyry::Logic::Invite->new;

    my $ret = eval { $logic->execute($params); } || {};
    $self->output_response_json($c, $ret, $@);
}

1;

