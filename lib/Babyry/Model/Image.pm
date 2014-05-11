package Babyry::Model::Image;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub get_by_image_id {
    my ($self, $teng, $image_id) = @_;

    return $teng->single(
        'image',
        {
            image_id => $image_id,
            disabled => 0,
        }
    );
}

sub get_by_image_ids {
    my ($self, $teng, $image_ids, $opt) = @_;

    $opt ||= {};

    return if ! @$image_ids;

    my $creteria = {
        image_id => $image_ids,
        disabled => 0,
        map { $_ => $opt->{$_} } keys %$opt
    };

    my $itr = $teng->search('image', $creteria);
    my %images = ();
    while ( my $r = $itr->next ) {
        $images{ $r->image_id } = $r->get_columns;
    }
    return \%images;
}

sub get_by_uploaded_by{
    my ($self, $teng, $uploaded_by, $from, $limit) = @_;

    $limit ||= 10;

    my $sql = <<QUERY;
    SELECT SQL_CALC_FOUND_ROWS
        *
    FROM
        image
    WHERE
        uploaded_by = ?
    AND
        disabled = ?
    ORDER BY
        created_at DESC
    LIMIT ?, ?
QUERY
    my @records =$teng->search_by_sql(
        $sql,
        [$uploaded_by, 0, $from, $limit]
    );
    my $found_row_count = $teng->dbh->selectrow_array(q{ SELECT FOUND_ROWS() });

    return (\@records, $found_row_count);
}

sub get_image_ids_by_rows{
    my ($rows) = @_;
    return [] if (!$rows || ref($rows) ne "ARRAY" || !scalar(@$rows));

    my @image_ids;
    for my $row (@$rows){
        push(@image_ids, $row->image_id) if($row->image_id);
    }

    return \@image_ids;
}

sub set_new_image {
    my ($self, $teng, $params) = @_;

    $teng->insert(
        'image',
        {
            image_id     => $params->{image_id},
            uploaded_by  => $params->{uploaded_by},
            created_at   => $params->{created_at},
            updated_at   => $params->{updated_at},
            format       => $params->{format},
            url          => $params->{url},
        }
    );
}

sub remove {
    my ($self, $teng, $image_id) = @_;

    $teng->update(
        'image',
        {
            disabled => 1,
        },
        {
            image_id => $image_id
        }
    );
}

sub get_image_by_updated_at{
    my ($self, $teng, $old_update, $limit) = @_;
    $limit ||= 10;
    my $sql = <<QUERY;
    SELECT image_id, uploaded_by, format FROM image WHERE updated_at < ? OR url = '' LIMIT ?
QUERY
    my @records =$teng->search_by_sql(
        $sql,
        [$old_update, $limit]
    );

    return (\@records);
}

sub get_total_size {
    my ($self, $teng, $user_id) = @_;
    my $sql = <<QUERY;
        select sum(size) as sum from image where uploaded_by = ?;
QUERY
    my @records =$teng->search_by_sql(
        $sql,
        [$user_id]
    );
    if ($records[0]->sum) {
        return $records[0]->sum;
    } else {
        return 0;
    }
}

sub update_url {
    my ($self, $teng, $id, $url, $time) = @_;
    $teng->update(
        'image' => {
            'url' => $url,
            'updated_at' => $time,
        }, {
            'image_id' => $id,
        }
    );
    return;
}

sub update_size {
    my ($self, $teng, $id, $size) = @_;
    $teng->update(
        'image' => {
            'size' => $size,
        }, {
            'image_id' => $id,
        }
    );
    return;
}


1;
