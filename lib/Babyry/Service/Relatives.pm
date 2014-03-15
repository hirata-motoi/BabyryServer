package Babyry::Service::Relatives;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;

sub get {
    my ($self, $user_id) = @_;

    my $teng      = $self->teng('BABYRY_MAIN_R');
    my $relatives = $self->model('Relatives')->get_by_user_id ($teng, $user_id);
    my $user      = $self->model('UserAuth')->get_by_ids( $teng, [ keys %$relatives ] );

    my %relatives_info = ();
    for my $relative_id ( keys %$relatives ) {
        $relatives_info{$relative_id} = {
            %{ $relatives->{$relative_id} },
            email => $user->{$relative_id}{email},
        }
    }
    return { relatives => \%relatives_info };
}

1;

