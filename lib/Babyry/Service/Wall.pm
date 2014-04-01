package Babyry::Service::Wall;
use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;
use Log::Minimal;

use SQL::Abstract;

sub show {
    my ($self, $user_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');

    # get relatives
    my $relatives = $self->model('Relatives')->get_by_user_id ($teng, $user_id );
    my $user      = $self->model('UserAuth')->get_by_ids( $teng, [ keys %$relatives ] );
    my %relatives_info = ();
    for my $relative_id ( keys %$relatives ) {
        $relatives_info{$relative_id} = {
            %{ $relatives->{$relative_id} },
            email => $user->{$relative_id}{email},
        }
    }

    # get child
    my %child_info = ();
    my $user_child_map = $self->model('UserChildMap')->get_child_by_user_id($teng, {user_id => $user_id});
    my $child = $self->model('Child')->new();
    for my $_child (@{$user_child_map}) {
        my $child_info = $child->get_by_child_id($teng, $_child->child_id);
        $child_info{$_child->child_id} = {
            id => $_child->child_id,
            name => $child_info->[0]->child_name,
        }
    }

    return { relatives => \%relatives_info, child => \%child_info };
}

1;

