package Babyry::Model::Relatives;

use strict;
use warnings;
use utf8;
use Log::Minimal;
use parent qw/Babyry::Model::Base/;
use SQL::Abstract;

use constant {
    RELATIVE_STATUS_UNADMITTED => 0,
    RELATIVE_STATUS_ADMITTED   => 1,
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
    while ( my $r = $itr->next ) {

        my $id;
        if ( $r->user_id == $user_id ) {
            $id = $r->relative_id;
            $relatives{$id} ||= {
                relative_id => $r->relative_id,
                created_at  => $r->created_at,
            };
            $relatives{$id}{self_apply_status} = $r->relative_status;
        } else {
            $id = $r->user_id;
            $relatives{$id} ||= {
                relative_id => $r->relative_id,
                created_at  => $r->created_at,
            };
            $relatives{$id}{opposite_apply_status} = $r->relative_status;
        }

        $relatives{$id}{relative_relation} = _relative_relation( $relatives{$id} ) or next;
        delete $relatives{$id}{self_apply_status};
        delete $relatives{$id}{opposite_apply_status};
    }

    return \%relatives;
}

sub _relative_relation {
    my $r = shift;

    my $self_apply_status = $r->{self_apply_status};
    my $opposite_apply_status = $r->{opposite_apply_status};

    return unless defined $self_apply_status && defined $opposite_apply_status;

    if ( $self_apply_status == 1 && $opposite_apply_status == 1) {
        return 'approved';
    }
    elsif ( $self_apply_status == 1 && $opposite_apply_status == 0 ) {
        return 'applying';
    }
    elsif ( $self_apply_status == 0 && $opposite_apply_status == 1) {
        return 'admitting';
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

