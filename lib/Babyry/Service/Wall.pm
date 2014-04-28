package Babyry::Service::Wall;
use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;
use Babyry::Service::User;

use Log::Minimal;
use SQL::Abstract;

sub show {
    my ($self, $user_id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');

    # get relatives
    my $relatives = $self->model('Relatives')->get_by_user_id($teng, $user_id );
    my $user      = $self->model('User')->get_by_user_ids( $teng, [ keys %$relatives ] );
    my $icon_urls = Babyry::Service::User->new->get_icon_urls({ user_info_list => $user });
    my %relatives_info = ();
    for my $relative_id ( keys %$relatives ) {
        $relatives_info{$relative_id} = +{
            %{ $relatives->{$relative_id} },
            user_name => $user->{$relative_id}{user_name},
            icon_url  => $icon_urls->{$relative_id},
        };
    }

    my %child_info = ();
    my $child_list = Babyry::Service::Child->new->get_related_child_list($user_id);
    for my $child ( @$child_list ) {
        $child_info{ $child->{child_id} } = +{
            child_id   => $child->{child_id},
            child_name => $child->{child_name},
            icon_url   => $child->{icon_url},
        };
    }

    return { relatives => \%relatives_info, child => \%child_info };
}

1;

