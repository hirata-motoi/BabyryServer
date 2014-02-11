package Babyry::Service::Session;
use strict;
use warnings;
use utf8;

use Digest::MD5 qw/md5_hex/;
use parent qw/Babyry::Service::Base/;

sub set {
    my ($self, $user_id, $session_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    $self->model('Session')->set($teng, $user_id, $session_id);
    $teng->txn_commit;
}

sub get {
    my ($self, $session_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');
    return $self->model('Session')->get($teng, $session_id);
}

1;

