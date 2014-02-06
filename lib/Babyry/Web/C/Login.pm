package Babyry::Web::C::Login;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Login;

sub index {
    my ($class, $c) = @_;

    return $c->render('login/index.tx');
}

sub execute {
    my ($class, $c) = @_;

    my $params = {
        email => $c->req->param('email') || '',
        password => $c->req->param('password') || '',
    };

    my $logic = Babyry::Logic::Login->new;

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

    if ($ret->{user_id}) {
        $c->session->set('session_id' => $ret->{session_id});
        return $c->redirect('/');
    } else {
        return $c->render('/login/index.tx', {error => 'INVALID_PASSWORD'});
    }

=pot
    my $user_id = $login->login($email, $password);

    if ($user_id) {
        my $session = Babyry::Logic::Session->new();
        my $session_id = $session->create($user_id);
        $c->session->set('session_id' => $session_id);
        $session->set($user_id, $session_id);
        return $c->redirect('/');
    } else {
        return $c->render('/login/index.tx', {error => 'INVALID_PASSWORD'});
    }
=cut
}

sub logout {
    my ($class, $c) = @_;

    $c->session->remove('session_id');
    $c->redirect('/login');
}

1;

