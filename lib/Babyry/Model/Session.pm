package Babyry::Model::Session;
use strict;
use warnings;
use utf8;

use Digest::MD5 qw/md5_hex/;
use parent qw/Babyry::Model::Base/;

sub set {
    my ($self, $teng, $params) = @_;

    my $session_id = $self->create($params->{user_id});

    my $expire = time() + 31 * 86400;
    $teng->insert(
        'session',
        {
            user_id => $params->{user_id},
            session_id => $session_id,
            expired_at => $expire,
        },
        'REPLACE'
    );

    return $session_id;
}

sub get {
    my ($self, $teng, $session_id, $now) = @_;

    my $row = $teng->single(
        'session',
        {
            session_id => $session_id,
            expired_at => { '>' => ( $now || time ) },
        }
    ) or return;

    return $row->user_id;
}

sub create {
    my ($self, $user_id) = @_;
    return md5_hex(time . $user_id);
}


1;

