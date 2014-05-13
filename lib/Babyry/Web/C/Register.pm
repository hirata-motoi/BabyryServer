package Babyry::Web::C::Register;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Data::Dumper;
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

sub withdraw {
    my ($self, $c) = @_;

    return $c->render('/register/withdraw.tx');
}

sub withdraw_execute {
    my ($self, $c) = @_;

   if (!$c->req->param('check1') || !$c->req->param('check2') || !$c->req->param('check3')) {
       return $c->render('/register/withdraw.tx', {error => 'UNCHECKED_BOX_EXIST'});
   }

    my $params = {
        withdraw_comment => $c->req->param('withdraw_comment') || '',
        user_id => $c->stash->{'user_id'},
    };

    my $logic = Babyry::Logic::Register->new;

    my $ret = eval { $logic->withdraw_execute($params); };
    if ( my $e = $@ ) {
        critf($e);
        return $c->render('/register/withdraw.tx', {error => 'UNKNOWN_ERRIR'});
    }

    return $c->redirect('/logout');
}

sub password_change {
    my ($self, $c) = @_;

    return $c->render(
        'top/index.tx',
        {  
            no_header => 1,
            no_footer => 1,
            login     => 0,
            register  => 0,
            activate  => 0,
            password_forget => 1,
            error => 'NO_MAILADDRESS',
        }
    ) if (!$c->req->param('email'));

    my $params = {
        email => $c->req->param('email'),
    };

    my $logic = Babyry::Logic::Register->new;

    my $ret = eval { $logic->password_change($params); };
    if ( my $e = $@ ) {
        critf($e);
    }

    return $c->render(
        'top/index.tx',
        {  
            no_header => 1,
            no_footer => 1,
            login     => 0,
            register  => 0,
            activate  => 0,
            password_forget => 1,
            error => $ret->{error},
        }
    ) if ($ret->{error});

    return $c->render(
        'top/index.tx',
        {  
            no_header => 1,
            no_footer => 1,
            password_change => 1,
            temp_password => 1,
            mail => $c->req->param('email') || '',
        }
    );
}

sub password_change_execute {
    my ($self, $c) = @_;

    my $error = "";

    $error = 'TOO_SHORT_PASSWORD' if (length($c->req->param('password')) < 8);
    $error = 'NEW_PASSWORD_NOT_MACH' if ($c->req->param('password') ne $c->req->param('password_confirm'));
    $error = 'NO_PASSWORD' if (!$c->req->param('pre_password'));
    $error = 'NO_PASSWORD' if (!$c->req->param('password'));

    return $c->render(
        'top/index.tx',
        {
            no_header => 1,
            no_footer => 1,
            password_change => 1,
            error => $error,
        }
    ) if ($error);

    my $params = {
        email => $c->req->param('email'),
        pre_password => $c->req->param('pre_password'),
        password => $c->req->param('password'),
    };
    my $logic = Babyry::Logic::Register->new;
    my $ret = eval { $logic->password_change_execute($params); };
    if ( my $e = $@ ) {
        critf($e);
    }

    return $c->render(
         'top/index.tx',
        {
            no_header => 1,
            no_footer => 1,
            login => 1,
        }
    );
}


sub new_password_change {
    my ($self, $c) = @_;

    return $c->render(
        'profile/new_password.tx',
        {
        }
    );
}

sub new_password_change_execute {
    my ($self, $c) = @_;

    my $error = "";

    $error = 'TOO_SHORT_PASSWORD' if (length($c->req->param('password')) < 8);
    $error = 'NEW_PASSWORD_NOT_MACH' if ($c->req->param('password') ne $c->req->param('password_confirm'));
    $error = 'NO_PASSWORD' if (!$c->req->param('pre_password'));
    $error = 'NO_PASSWORD' if (!$c->req->param('password'));

    return $c->render(
        'profile/new_password.tx',
        {
            error => $error,
        }
    ) if ($error);

    my $params = {
        user_id => $c->stash->{'user_id'},
        pre_password => $c->req->param('pre_password'),
        password => $c->req->param('password'),
    };
    my $logic = Babyry::Logic::Register->new;
    my $ret = eval { $logic->new_password_change_execute($params); };
    if ( my $e = $@ ) {
        critf($e);
    }

    return $c->render(
        'profile/new_password.tx',
        {  
            error => $ret->{error},
        }
    ) if ($ret->{error});

    return $c->redirect('/');
}


1;

