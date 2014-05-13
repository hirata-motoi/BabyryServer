package Babyry::Model::UserAuth;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Model::Base/;
use Log::Minimal;

sub create {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'user_auth',
        {
            user_id     => $params->{user_id},
            email        => $params->{email},
            password_hash  => $params->{password_hash},
            created_at => $params->{created_at},
            updated_at => $params->{updated_at},
        }
    );
}

sub login {
    my ($self, $teng, $params) = @_;

    my $res = $teng->single(
        'user_auth',
        { 
            email => $params->{email},
            password_hash => $params->{enc_pass},
        }
    );
    my $user_id = $res->user_id;

    return $user_id;
}

sub get_by_ids {
    my ($self, $teng, $user_ids) = @_;

    return {} unless ( $user_ids && scalar @$user_ids );

    my $itr = $teng->search(
        'user_auth',
        {
            user_id => $user_ids,
        }
    );
    my %user_auth = ();
    while ( my $r = $itr->next ) {
        $user_auth{ $r->user_id } = $r->get_columns;
    }
    return \%user_auth;
}

sub get_by_email {
    my ($self, $teng, $params) = @_;

    my $row = $teng->single('user_auth', {
        email => $params->{'email'},
        disabled => 0,
    }) or return;

    return $row->email;
}

sub update_tmp_password {
    my ($self, $teng, $params) = @_;

    return $teng->update(
        'user_auth',
        {  
            tmp_password_hash => $params->{tmp_password_hash},
        },
        {  
            email => $params->{email},
        },
    );
}

sub update_password {
    my ($self, $teng, $params) = @_;

    return $teng->update(
        'user_auth',
        {  
            password_hash => $params->{password_hash},
        },
        {
            user_id => $params->{user_id},
        },
    );
}

sub get_temp_password {
    my ($self, $teng, $params) = @_;

    my $row = $teng->single('user_auth', {
        email => $params->{'email'},
        disabled => 0,
    }) or return '';

    return $row->tmp_password_hash;
}

1;

