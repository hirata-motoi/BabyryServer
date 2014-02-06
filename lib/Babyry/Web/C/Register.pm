package Babyry::Web::C::Register;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
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
    if ( $ret->{error} ) {
critf($ret->{error});
#        critf('Failed to register params:%s error:%s', $self->dump($params), $self->dump( $ret->{error} ));
#        $c->render_500();
    }

    $c->redirect('/register/invite_code/index.tx');
}

sub verify {
    my ($self, $c) = @_;

    my $token = $c->req->param('token') || '';
    my $logic = Babyry::Logic::Register->new;

    my $ret = eval { $logic->verify($token) };
    if ( my $e = $@ ) {
        critf('Failed to verify registered email token:%s', $token);
        return $c->render_500();
    }
    return $c->render('/', +{});
}
 
1;
