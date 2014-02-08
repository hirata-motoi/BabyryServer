package Babyry::Service::Login;

use strict;
use warnings;
use utf8;
use Log::Minimal;
use parent qw/Babyry::Base/;

use Babyry::Logic::Common;
use Babyry::Model::User_Auth;
use Babyry::Model::Session;
use Babyry::Model::User;

sub execute {
    my ($self, $params) = @_;
    my $user_auth = Babyry::Model::User_Auth->new();

    # login
    my $common = Babyry::Logic::Common->new;
    my $enc_pass = $common->enc_password($params->{password});
    my $teng_r = $self->teng('BABYRY_MAIN_R');
    my $user_id = $user_auth->login(
        $teng_r, 
        { email => $params->{email}, enc_pass => $enc_pass}
    );

    if ($user_id) {
        # check user status
        my $user = Babyry::Model::User->new();
        my $user_status = $user->get_status(
            $teng_r,
            { user_id => $user_id },
        );
        if ($user_status == 0) {
            return { error => 'USER_NOT_VERIFIED' };
        }
        $teng_r->disconnect();

        my $teng_w = $self->teng('BABYRY_MAIN_W');
        $teng_w->txn_begin;
        # if user_id session set
        my $session = Babyry::Model::Session->new();
        my $session_id = $session->set(
            $teng_w,
            {
                user_id => $user_id,
            }
        );
        $teng_w->txn_commit;
        $teng_w->disconnect();
        return { user_id => $user_id, session_id => $session_id };
    } else {
        # unless user_id redirect to index with error message
        return { error => 'LOGIN_ERROR' };
    }
}

1;
