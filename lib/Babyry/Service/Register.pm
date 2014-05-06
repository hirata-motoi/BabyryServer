package Babyry::Service::Register;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Digest::MD5 qw/md5_hex/;
use Log::Minimal;
use Data::Dumper;
use Carp;

sub execute {
    my ($self, $params) = @_;

    my $error = '';

    # username varidation
    if ($params->{email} !~ /^([^\s]+)@([^\s]+)$/) {
        return { error => 'INVALID_MAIL_ADDRESS' };
    }

    # password varidation
    $error = $self->varidate_password($params->{password});
    return { error => $error } if ($error);

    # passowrd match check
    $error = $self->match_password($params->{password}, $params->{password_confirm});
    return { error => $error } if ($error);

    my $teng   = $self->teng('BABYRY_MAIN_W');
    my $teng_r = $self->teng('BABYRY_MAIN_R');

    my $user_id    = $self->model('Sequence')->get_id($teng, 'seq_user');
    my $unixtime   = time();
    my $expired_at = $self->get_expired_at($unixtime);
    my $token      = $self->create_token($user_id);
    my $key        = $self->create_activate_key();

    my $user           = $self->model('User');
    my $user_auth      = $self->model('UserAuth');
    my $activate_key   = $self->model('ActivateKey');
    my $mail           = $self->model('AmazonSES');
    my $invite         = $self->model('Invite');
    my $relatives      = $self->model('Relatives');


    # duplicate check 'email from user_auth'
    if ($user_auth->get_by_email($teng_r, {email => $params->{email}})) {
        return { error => 'DUPLICATE_ENTRY' };
    }

    my $invite_record = $invite->get_by_invite_code($teng_r, $params->{invite_code});

    # insert user table
    $teng->txn_begin;
    eval {
        $user->create(
            $teng,
            {
                user_id => $user_id,
                created_at => $unixtime,
                updated_at => $unixtime,
            }
        );

        $user_auth->create(
            $teng,
            {
                user_id => $user_id,
                email         => $params->{email},
                password_hash => $self->model('Common')->enc_password($params->{password}),
                created_at => $unixtime,
                updated_at => $unixtime,
            }
        );

        $activate_key->create(
            $teng,
            {
                user_id    => $user_id,
                key        => $key,
                expired_at => $expired_at,
            }
        );

        # 招待者からrelativesの申請を受けたことになっているので承認する
        if ( $invite_record ) {
            $invite->acknowledge($teng, $user_id, $invite_record->{invite_code});
            $relatives->request(
                $teng,
                {
                    user_id         => $invite_record->{user_id},
                    relative_id     => $user_id,
                    relative_status => 0,
                    created_at      => $unixtime
                }
            );
        }
        $teng->txn_commit;
        $teng->disconnect();
    };
    if ( my $e = $@ ) {
        $teng->txn_rollback;
        $teng->disconnect();
        croak($e);
    }

    # TODO subject/body + sendを1つのmethodに任せる
    # TODO evalの中に移動
    $mail->set_subject(Babyry::Common->config->{verify}{mail}{subject});
    $mail->set_body( sprintf(Babyry::Common->config->{verify}{mail}{body}, $key) );

    if ($ENV{APP_ENV} eq 'production') {
        $mail->set_address($params->{email});
    } else {
        $mail->set_address('meaning.sys@gmail.com');
    }
    $mail->send_mail();
}

sub activate {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;

    my $activate_key = $self->model('ActivateKey');
    my $user         = $self->model('User');
    my $relatives    = $self->model('Relatives');
    my $invite       = $self->model('Invite');

    eval {
        my $deleted_key = $activate_key->delete($teng, $params)
            or croak("register_key is invalid key:%s", $params->{key});
        $user->update_to_verified($teng, { user_id => $params->{user_id} })
            or croak( sprintf('Failed to update_to_verified user_id:%d', $params->{user_id}) );

        my $invite_record = $invite->get_by_invited_user($teng, $params->{user_id});
        if ($invite_record) {
            $invite->admit($teng, $invite_record);
            $relatives->admit($teng, $params->{user_id}, $invite_record );
        }

        $teng->txn_commit;

        # logging
        infof('register_key was deleted : %s', $self->dump($deleted_key));
    };
    if ( my $e = $@ ) {
        $teng->txn_rollback;
        infof($e);
        return {error => 'INVALID_KEY'};
    }
    return {};
}

=pot
# TODO tokenのverifyをvalidatorでやる
# 基本的にはerror messageを返すのはvalidationで検知したerrorに対して。
# Service以下で起きたexceptionは本当の例外なのでcroakしてOK
sub verify {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;

    # TODO create instances by Service::factory
    my $register_token  = $self->model('RegisterToken');
    my $relatives       = $self->model('Relatives');
    my $invite          = $self->model('Invite');
    my $user            = $self->model('User');

    eval {
        my $deleted_register_token = $register_token->delete($teng, $params->{token})
            or croak('register_token is invalid token:%s', $params->{token});

        # TODO magic number
        my $user_id = $deleted_register_token->{user_id};
        $user->update_to_verified($teng, { user_id => $user_id })
            or croak( sprintf('Failed to update_to_verified user_id:%d', $user_id) );

        # not invited user
        my $invite_record = $invite->get_by_invited_user($teng, $user_id);

        if ($invite_record) {
            $invite->admit($teng, $invite_record);
            $relatives->admit($teng, $user_id, $invite_record );
        }

        $teng->txn_commit;

        # logging
        infof('register_token was deleted : %s', $self->dump($deleted_register_token));
    };
    if ( my $e = $@ ) {
        $teng->txn_rollback;
        croak($e);
    }
}
=cut


sub varidate_password {
    my ($self, $password) = @_;
    if($password eq '') {
        return 'NO_PASSWRD';
    }
    if(length($password) < 8 ) {
        return 'TOO_SHORT_PASSWRD';
    }
    return 0;
}

# TODO move to Babyry::Validator::Register
sub match_password {
    my ($self, $password, $password_confirm) = @_;

    return 'NOT_MATCH_PASSWORD' if ($password ne $password_confirm);

    return 0;
}

sub get_expired_at {
    my ($self, $unixtime) = @_;
    return $unixtime + 3600 * 24; # TODO move to config
}

sub create_token {
    my ($self, $user_id) = @_;
    return md5_hex(time . $user_id . Babyry::Common->get_key_vault('register_secret'));
}

sub create_activate_key {
    my ($self) = @_;
    return sprintf("%04d", int(rand(10000)));
}

sub devicetoken {
    my ($self, $params) = @_;

    my $sns = $self->model('AmazonSNS')->set_endpoint($params);
    return {} if (!$sns>{'EndpointArn'});

    $params->{arn} = $sns->{'EndpointArn'};
    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    $self->model('PushToken')->set($teng, $params);
    $teng->txn_commit;
    $teng->disconnect();

    return {};
}

sub is_verified {
    my ($self, $user_id) = @_;
    my $teng_r = $self->teng('BABYRY_MAIN_R');

   return $self->model('User')->is_verified($teng_r, {user_id => $user_id});
}

1;

