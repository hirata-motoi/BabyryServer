package Babyry::Web::C::Top;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;

sub index {
    my ($class, $c) = @_;

    my $login = 0;
    $login = 1 if ($c->req->param('login'));
    my $register = 0;
    my $register = 1 if ($c->req->param('register'));
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
            register  => $register
        }
    );
}

1;

