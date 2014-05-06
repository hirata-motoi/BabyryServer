package Babyry::Web::C::Top;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Register;

sub index {
    my ($class, $c) = @_;

    my $login = 0;
    $login = 1 if ($c->req->param('login'));
    my $register = 0;
    $register = 1 if ($c->req->param('register'));
    # 排他処理、起こらないはず
    if ($login) {
        $register = 0;
    }

    return $c->render(
        'top/index.tx',
        {
            no_header => 1,
            no_footer => 1,
            login     => $login,
            register  => $register,
            activate  => 0,
        }
    );
}

sub activate {
    my ($class, $c) = @_;

    return $c->render(
        'top/index.tx',
        {
            no_header => 1,
            no_footer => 1,
            login     => 0,
            register  => 0,
            activate  => 1,
        }
    );
}

sub activate_execute {
    my ($class, $c) = @_;

    my $params = {
        key => $c->req->param('activate_key') || '',
        user_id => $c->stash->{'user_id'} || '',
    };

    my $logic = Babyry::Logic::Register->new;

    my $res = eval { $logic->activate($params) };
    if ( my $e = $@ ) {
        critf('Failed to verify registered email token:%s error:%s', $params->{token}, $e);
        return $c->res_500();
    }

    if ($res eq 'HASH' && $res->{error}) {
        return $c->render(
            'top/index.tx',
            {
                no_header => 1,
                no_footer => 1,
                login     => 0,
                register  => 0,
                activate  => 1,
                error     => $res->{error},
            }
        );
    } else {
        return $c->redirect('/');
    }
}

1;

