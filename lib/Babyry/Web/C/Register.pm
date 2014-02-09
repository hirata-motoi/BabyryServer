package Babyry::Web::C::Register;

use strict;
use warnings;
use parent qw/Babyry::Web::C Babyry::Base/;
use Log::Minimal;
use Babyry::Logic::Register;

sub index {
    my ($self, $c) = @_;

    return $c->render('/register/index.tx');
}

sub execute {
    my ($self, $c) = @_;

    my $params = {
        email => $c->req->param('email') || '',
        password => $c->req->param('password') || '',
        password_confirm => $c->req->param('password_confirm') || '',
        invite_code => $c->req->param('invite_code') || '',
    };

    my $logic = Babyry::Logic::Register->new;

    my $ret = eval { $logic->execute($params); };
    if ( my $e = $@ ) {
critf($e);
#        critf('Failed to register params:%s error:%s', $self->dump($params), $e);
#        $c->render_500();
    }
    $c->redirect('/login');
}

sub verify {
    my ($self, $c, $p, $v) = @_;

    my $params = {
        token => $c->req->param('token') || '',
    };

    my $logic = Babyry::Logic::Register->new;

    eval { $logic->verify($params) };
    if ( my $e = $@ ) {
        critf('Failed to verify registered email token:%s error:%s', $params->{token}, $e);
        return $c->res_500();
    }
    return $c->redirect('/login', +{});
}

1;

