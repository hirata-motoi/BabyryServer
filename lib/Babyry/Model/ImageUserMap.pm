package Babyry::Model::ImageUserMap;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub add{
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'image_user_map',
        {
            image_id   => $params->{image_id},
            user_id    => $params->{user_id},
            disabled   => $params->{disabled},
            created_at => $params->{created_at},
            updated_at => $params->{updated_at},
        }
    );
    return;
}

sub get_image_ids_by_user_id {
    my ($self, $teng, $user_id) = @_;

    my $itr = $teng->search(
        'image_user_map',
        {
            user_id  => $user_id,
            disabled => 0,
        }
    );

    my @image_ids = ();
    while ( my $r = $itr->next ) {
        push @image_ids, $r->image_id;
    }
    return \@image_ids;
}


sub get_by_user_id{
    my ($teng, $user_id, $from, $limit) = @_;

    $limit ||= 10;

    my $sql = <<QUERY;
    SELECT SQL_CALC_FOUND_ROWS
        *
    FROM
        image_user_map
    WHERE
        user_id = ?
    AND
        disabled = ?
    ORDER BY
        created_at DESC
    LIMIT ?, ?
QUERY
    my @records =$teng->search_by_sql(
        $sql,
        [$user_id, 0, $from, $limit]
    );
    my $found_row_count = $teng->dbh->selectrow_array(q{ SELECT FOUND_ROWS() });

    return (\@records, $found_row_count);
}

1;
