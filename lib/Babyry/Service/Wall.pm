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
    my $child = $self->model('Child')->new();
    my %relatives_info = ();
    my %child_info = ();
    for my $relative_id ( keys %$relatives ) {
        $relatives_info{$relative_id} = {
            %{ $relatives->{$relative_id} },
            email => $user->{$relative_id}{email},
        };
        # add child info by relative_id
        my $_child_array = $child->get_by_created_by($teng, $relative_id);
        for my $_child (@{$_child_array}) {
            $child_info{$_child->child_id} = {
                id => $_child->child_id,
                name => $_child->child_name,
                parent_id => $relative_id,
            };
        }
    }

    return { relatives => \%relatives_info, child => \%child_info };
}

1;

