package Babyry::Model::UserAlbumMap;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub get_by_user_id {
    my ($self, $teng, $params) = @_;

    my $res = $teng->search(
        'user_album_map',
        {
            user_id  => $params->{user_id},
        }
    );

    my @album_ids = ();
    while ( my $r = $res->next ) {
        push @album_ids, $r->album_id;
    }
    return \@album_ids;
}

1;
