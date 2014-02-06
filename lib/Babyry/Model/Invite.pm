package Babyry::Model::Invite;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Base/;
use String::Random;
use Log::Minimal;

use constant {
    INVITE_CODE_LENGTH => 8,
    STATUS_ADMITTED    => 'admitted',
    STATUS_REQUESTED   => 'requested',
};

sub create {
    my ($self, $params, $now) = @_;

    $now ||= time;

    my $invite_code = '';
    my $row;
    for (1 .. 3) {

        $row = eval {
            $self->teng->insert(
                'invite',
                {
                    user_id     => $params->{user_id},
                    invite_code => _create_invite_code(),
                    created_at  => $now,
                }
            );
        };
        if ($@ || ! $row) {
            warnf('insert into invite error:%s', $@ || '');
            next;
        }
        last;
    }

    if (! $row ) {
        croakf('Failed to invite params:%s error:%s', $self->dump($params), $@);
    }
    return $row->get_columns;
}

sub _create_invite_code {
    return String::Random->new->randregex(sprintf('[A-Za-z0-9]{%s}',  INVITE_CODE_LENGTH));
}

sub get_by_invite_code {
    my ($self, $invite_code) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');
    my $invite = $teng->single(
        'invite',
        {
            invite_code => $invite_code || ''
        }
    ) or return;
    $invite->get_columns;
}

sub get_by_invited_user {
    my ($self, $invited_user_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');
    my $row = $teng->single(
        'invite',
        {
            invited_user_id => $invited_user_id,
        }
    );
    return $row ? $row->get_columns : undef;
}

sub admit {
    my ($self, $invite_record) = @_;

    my $ret = $self->tengw->update(
        'invite',
        {
            status => STATUS_ADMITTED,
        },
        {
            invited_user_id => $invite_record->{invited_user_id},
            user_id         => $invite_record->{user_id},
            status          => STATUS_REQUESTED,
        }
    ) or croakf('Failed to admit invite row:%s', $self->dump($invite_record));
}

1;

