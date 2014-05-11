package Babyry::Model::ImageUserMap;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

use Log::Minimal;

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

sub get_by_conditions {
    my ($teng, $user_id, $child_id, $from, $limit) = @_;
    # child_idが無ければuser_idのみで引く
    if ( ! scalar @{$child_id} ) {
        my ($images, $found_row_count) = get_by_user_id($teng, $user_id, $from, $limit);
        return ($images, $found_row_count);
    }
    # child_idあり
    else {
        my ($images, $found_row_count) = get_by_user_id_child_id($teng, $user_id, $child_id, $from, $limit);
        return ($images, $found_row_count);
    }
}

sub get_by_user_id {
    my ($teng, $user_id, $from, $limit) = @_;

    $limit ||= 10;

    my $sql = <<QUERY;
    SELECT   SQL_CALC_FOUND_ROWS img.*, map.*
    FROM     image AS img 
      JOIN   image_user_map AS map
    WHERE    img.image_id = map.image_id
      AND    map.user_id = ?
      AND    map.disabled = ?
      AND    img.disabled = ?
    ORDER BY map.created_at DESC
    LIMIT ?, ?
QUERY
    my @records =$teng->search_by_sql(
        $sql,
        [$user_id, 0, 0, $from, $limit]
    );
    my $found_row_count = $teng->dbh->selectrow_array(q{ SELECT FOUND_ROWS() });

    return (\@records, $found_row_count);
}

sub get_by_user_id_child_id {
    my ($teng, $user_id, $child_id, $from, $limit) = @_;

    $limit ||= 10;

    my $child_ids = join(',', @{$child_id});

    my $sql = <<QUERY;
    SELECT   SQL_CALC_FOUND_ROWS *
    FROM     image_user_map
      JOIN   image_child_map
      JOIN   image
    WHERE    user_id = ?
      AND    image_user_map.image_id = image_child_map.image_id
      AND    image.image_id = image_user_map.image_id
      AND    child_id in (?)
      AND    image_user_map.disabled = ?
      AND    image.disabled = ?
    ORDER BY image_user_map.created_at DESC
    LIMIT ?, ?
QUERY
    my @records =$teng->search_by_sql(
        $sql,
        [$user_id, $child_ids, 0, 0, $from, $limit]
    );
    my $found_row_count = $teng->dbh->selectrow_array(q{ SELECT FOUND_ROWS() });

    return (\@records, $found_row_count);
}

1;

