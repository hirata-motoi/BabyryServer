package Babyry::Web::C::Register;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Register;
use Babyry::Logic::Login;

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
        domain => $c->stash->{'domain'} || '',
    };

    my $logic = Babyry::Logic::Register->new;

    my $ret = eval { $logic->execute($params); };
    if ( my $e = $@ ) {
critf($e);
#        critf('Failed to register params:%s error:%s', $self->dump($params), $e);
#        $c->render_500();
    }
    if ($ret eq 'HASH' and $ret->{error}) {
        return $c->render(
            'top/index.tx',
            {
                no_header => 1,
                no_footer => 1,
                register  => 1,
                error     => $ret->{error},
            }
        );
    }

    my $email = $c->req->param('email');
    my $password = $c->req->param('password');
    return $c->redirect("/login/execute?email=$email&password=$password"); 
}
=pot
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
    return $c->render(
        'top/index.tx',
        {
            no_header => 1,
            no_footer => 1,
        }
    );
}
=cut

sub devicetoken {
    my ($self, $c) = @_;

    if (!$c->stash->{'user_id'}) {
        return $c->render_json({error => "no_user_id"});
    }
    if (!$c->req->param('devicetoken')) {
        return $c->render_json({error => "no_devicetoken"});
    }

    my $params = {
        devicetoken => $c->req->param('devicetoken'),
        user_id => $c->stash->{'user_id'},
    };

    my $logic = Babyry::Logic::Register->new;

    my $ret = eval { $logic->devicetoken($params); };
    if ( my $e = $@ ) {
        critf($e);
        return $c->render_json({error => "internal_server_error"});
    }
    return $c->render_json($ret);
}

1;

