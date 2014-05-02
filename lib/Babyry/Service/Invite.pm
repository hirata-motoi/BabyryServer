package Babyry::Service::Invite;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use URI::Escape;

sub execute {
    my ($self, $params) = @_;

    infof('invite_method=%s user_id=%d', @{$params}{qw/invite_method user_id/});

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    my $model = $self->model('Invite');
    my $row = eval {
        my $row = $model->create($teng, $params);
        $teng->txn_commit;
        $row;
    };
    if ( my $e = $@ ) {
        $teng->txn_rollback;
        croakf($e);
    }

    return $self->_create_invite_mail_params( @{$row}{qw/invite_code user_id/}, $params->{domain} );
}

sub _create_invite_mail_params {
    my ($self, $invite_code, $user_id, $domain) = @_;

    my %mail_params = (
        subject => uri_escape( Babyry::Common->config->{invite}{mail}{subject} ),
    );

    my $body_tmpl = Babyry::Common->config->{invite}{mail}{body};
    $mail_params{body} = uri_escape( sprintf($body_tmpl, $invite_code, $domain) );

    return \%mail_params;
}

1;

