package Babyry::Web::C::Login;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Login;

sub index {
    my ($class, $c) = @_;

    return $c->render(
        'top/index.tx',
        {  
            no_header => 1,
            no_footer => 1,
        }
    );
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
        $c->session->session_cookie->{expires} = time() + 9*60*60 + 31*24*60*60;
        return $c->redirect('/');
    } else {
        return $c->render(
            'top/index.tx',
            {  
                no_header => 1,
                no_footer => 1,
                login     => 1,
                error => 'INVALID_PASSWORD',
            }
        );
    }
}

sub logout {
    my ($class, $c) = @_;

    $c->session->remove('session_id');
    return $c->render(
        'top/index.tx',
        {  
            no_header => 1,
            no_footer => 1,
        }
    );
}

1;

