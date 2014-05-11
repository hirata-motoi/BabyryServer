package Babyry::Service::Login;

use strict;
use warnings;
use utf8;
use Log::Minimal;
use parent qw/Babyry::Service::Base/;

sub execute {
    my ($self, $params) = @_;
    my $user_auth = $self->model('UserAuth');

    # login
    my $common = $self->model('Common');
    my $enc_pass = $common->enc_password($params->{password});
    my $teng_r = $self->teng('BABYRY_MAIN_R');
    my $user_id = $user_auth->login(
        $teng_r, 
        { email => $params->{email}, enc_pass => $enc_pass}
    );

    if ($user_id) {
        # check user status
        my $user = $self->model('User');
        my $is_verified = $user->is_verified(
            $teng_r,
            { user_id => $user_id },
        );
        $teng_r->disconnect();

        my $is_disabled = $user->is_disabled(
            $teng_r,
            { user_id => $user_id },
        );
        return { error => 'LOGIN_ERROR' } if ($is_disabled);

        my $teng_w = $self->teng('BABYRY_MAIN_W');
        $teng_w->txn_begin;
        # if user_id session set
        my $session = $self->model('Session');
        my $session_id = $session->set(
            $teng_w,
            {
                user_id => $user_id,
            }
        );
        $teng_w->txn_commit;
        $teng_w->disconnect();

        # 認証済みでなくてもsessionは渡す
        # 認証キー入力画面に進むため
        if ( ! $is_verified ) {
            return { user_id => $user_id, session_id => $session_id, not_verified => 1};
        }
        return { user_id => $user_id, session_id => $session_id };
    } else {
        # unless user_id redirect to index with error message
        return { error => 'LOGIN_ERROR' };
    }
}

1;
