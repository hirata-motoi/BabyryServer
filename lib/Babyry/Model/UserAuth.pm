package Babyry::Model::UserAuth;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Base/;
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
    my ($self, $user_ids) = @_;

    return {} unless ( $user_ids && scalar @$user_ids );

    my $itr = $self->teng('BABYRY_MAIN_R')->search(
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



1;

