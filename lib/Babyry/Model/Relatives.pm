package Babyry::Model::Relatives;

use strict;
use warnings;
use utf8;
use Log::Minimal;
use parent qw/Babyry::Model::Base/;
use SQL::Abstract;
use Carp;

use constant {
    RELATIVE_STATUS_UNADMITTED  => 0,
    RELATIVE_STATUS_ADMITTED    => 1,
    RELATIVE_STATUS_CANCELED    => 2,
    RELATIVE_STATUS_REJECTED    => 3,
    RELATIVE_STATUS_dissolved   => 4,
};

sub get_by_user_id {
    my ($self, $teng, $user_id) = @_;

    my $sqla = SQL::Abstract->new;

    my $creteria = [
        { user_id     => $user_id },
        { relative_id => $user_id }
    ];
    my ($stmt, @bind) = $sqla->select(
        'relatives',
        [qw/user_id relative_id relative_status created_at/],
        [
            { user_id     => $user_id },
            { relative_id => $user_id }
        ]
    );

    my $itr = $teng->search_by_sql($stmt, \@bind);
    my %relatives = ();
    my %relative_status = ();
    while ( my $r = $itr->next ) {

        my $id;
        if ( $r->user_id == $user_id ) {
            $id = $r->relative_id;
            $relatives{$id} ||= {
                relative_id => $r->relative_id,
                created_at  => $r->created_at,
            };
            $relative_status{$id}{self_relative_status} = $r->relative_status;
        } else {
            $id = $r->user_id;
            $relatives{$id} ||= {
                relative_id => $r->relative_id,
                created_at  => $r->created_at,
            };
            $relative_status{$id}{opposite_relative_status} = $r->relative_status;
        }

        $relatives{$id}{relative_relation} = _relative_relation( $relative_status{$id} ) or next;
    }

    return \%relatives;
}

sub _relative_relation {
    my $r = shift;

    my $self_relative_status     = $r->{self_relative_status};
    my $opposite_relative_status = $r->{opposite_relative_status};

    return unless defined $self_relative_status && defined $opposite_relative_status;

    if ( $self_relative_status == 1 && $opposite_relative_status == 1) {
        return 'approved';
    }
    elsif ( $self_relative_status == 1 && $opposite_relative_status == 0 ) {
        return 'applying';
    }
    elsif ( $self_relative_status == 0 && $opposite_relative_status == 1 ) {
        return 'admitting';
    }
    elsif ( $self_relative_status == 2 && $opposite_relative_status == 0 ) {
        return 'cancel';
    }
    elsif ( $self_relative_status == 0 && $opposite_relative_status == 2 ) {
        return 'canceled';
    }
    elsif ( $self_relative_status == 1 && $opposite_relative_status == 3 ) {
        return 'reject';
    }
    elsif ( $self_relative_status == 3 && $opposite_relative_status == 1 ) {
        return 'rejected';
    }
    elsif ( $self_relative_status == 4 && $opposite_relative_status == 1 ) {
        return 'dissolve';
    }
    elsif ( $self_relative_status == 1 && $opposite_relative_status == 4 ) {
        return 'dissolved';
    }
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
        croak( sprintf('Failed to admit relatives user_id:%d relative_id:%d', $invite_record->{user_id}, $user_id) );
    }
}

sub _create {
    my ($self, $teng, $user_id, $relative_id, $relative_status, $now) = @_;

    $now ||= time;

    my ($stmt, @bind) = $self->maker->insert_multi(
        'relatives',
        [
            {
                user_id         => $user_id,
                relative_id     => $relative_id,
                relative_status => $relative_status,
                created_at      => $now,
            }
        ],
        +{
            update => { relative_status => $relative_status }
        }
    );
    $teng->do($stmt, undef, @bind);
}

sub cancel {
    my ($self, $teng, $user_id, $relatives) = @_;

    my $lock_self_row = $teng->lookup(
        'relatives',
        {
            user_id     => $user_id,
            relative_id => $relatives->{user_id},
        }
    );
    my $lock_opposite_row = $teng->lookup(
        'relatives',
        {
            user_id     => $relatives->{user_id},
            relative_id => $user_id,
        }
    );
    croak( sprintf('Failed to get lock user_id:%d relative_id:%d', $user_id, $relatives->{user_id}) )
        unless $lock_self_row && $lock_opposite_row;

    my $ret = $teng->update(
        'relatives',
        {
            relative_status => RELATIVE_STATUS_CANCELED,
        },
        {
            user_id     => $user_id,
            relative_id => $relatives->{user_id},
        }
    );
    if ( ! $ret ) {
        croak( sprintf('Failed to cancel relatives user_id:%d relative_id:%d', $user_id, $relatives->{user_id}) );
    }
}

sub reject {
    my ($self, $teng, $user_id, $relatives) = @_;

    my $lock_self_row = $teng->lookup(
        'relatives',
        {
            user_id     => $user_id,
            relative_id => $relatives->{user_id},
        }
    );
    my $lock_opposite_row = $teng->lookup(
        'relatives',
        {
            user_id     => $relatives->{user_id},
            relative_id => $user_id,
        }
    );
    croak( sprintf('Failed to get lock user_id:%d relative_id:%d', $user_id, $relatives->{user_id}) )
        unless $lock_self_row && $lock_opposite_row;

    my $ret = $teng->update(
        'relatives',
        {
            relative_status => RELATIVE_STATUS_REJECTED,
        },
        {
            user_id     => $user_id,
            relative_id => $relatives->{user_id},
        }
    );
    if ( ! $ret ) {
        croak( sprintf('Failed to reject relatives user_id:%d relative_id:%d', $user_id, $relatives->{user_id}) );
    }
}

1;

