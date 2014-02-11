package Babyry::Model::Relatives;

use strict;
use warnings;
use utf8;
use Log::Minimal;
use parent qw/Babyry::Model::Base/;

use constant {
    RELATIVE_STATUS_UNADMITTED => 0,
    RELATIVE_STATUS_ADMITTED   => 1,
};

sub get_by_user_id {
    my ($self, $teng, $user_id) = @_;

    my $itr = $teng->search(
        'relatives',
        {
            user_id         => $user_id,
            relative_status => RELATIVE_STATUS_ADMITTED,
        }
    );
    my %relatives = ();
    while ( my $r = $itr->next ) {
        $relatives{ $r->relative_id } = $r->get_columns;
    }
    return \%relatives;
}

sub request {
    my ($self, $teng, $params) = @_;

    $self->_create($teng, @{$params}{qw/user_id relative_id/}, RELATIVE_STATUS_ADMITTED);
    $self->_create($teng, @{$params}{qw/relative_id user_id/}, RELATIVE_STATUS_UNADMITTED);
}

sub admit {
    my ($self, $teng, $user_id, $invite_record) = @_;

    my $ret = $teng->update(
        'relatives',
        {
            relative_status => RELATIVE_STATUS_ADMITTED,
        },
        {
            user_id     => $user_id,
            relative_id => $invite_record->{user_id},
        }
    );
    if ( ! $ret ) {
        croak('Failed to admit relatives user_id:%d relative_id:%d', $invite_record->{user_id}, $user_id);
    }
}

sub _create {
    my ($self, $teng, $user_id, $relative_id, $relative_status, $now) = @_;

    $now ||= time;

    $teng->insert(
        'relatives',
        {
            user_id         => $user_id,
            relative_id     => $relative_id,
            relative_status => $relative_status,
            created_at      => $now,
        },
        'INSERT IGNORE',
    );
}

1;

