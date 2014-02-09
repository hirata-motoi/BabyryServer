package Babyry::Service::Wall;
use strict;
use warnings;
use utf8;

use parent qw/Babyry::Base/;
use Log::Minimal;
use Babyry::Model::Relatives;
use Babyry::Model::User_Auth;

use SQL::Abstract;

sub show {
    my ($self, $user_id) = @_;

    my $relatives = Babyry::Model::Relatives->new->get_by_user_id($user_id);
    my $user = Babyry::Model::User_Auth->new->get_by_ids( [ keys %$relatives ] );

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

