package Babyry::Service::Session;
use strict;
use warnings;
use utf8;

use Digest::MD5 qw/md5_hex/;
use parent qw/Babyry::Service::Base/;
use Babyry::Model::Session;

sub set {
    my ($self, $user_id, $session_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    Babyry::Model::Session->new->set($teng, $user_id, $session_id);
    $teng->txn_commit;
}

sub get {
    my ($self, $session_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');
    return Babyry::Model::Session->new->get($teng, $session_id);
}

1;

