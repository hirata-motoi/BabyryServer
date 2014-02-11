package Babyry::Service::Wall;
use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use Babyry::Model::Relatives;
use Babyry::Model::UserAuth;

use SQL::Abstract;

sub show {
    my ($self, $user_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');

    my $relatives = Babyry::Model::Relatives->new->get_by_user_id($teng, $user_id);
    my $user = Babyry::Model::UserAuth->new->get_by_ids( $teng, [ keys %$relatives ] );

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

