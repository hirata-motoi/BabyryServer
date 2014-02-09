package Babyry::Model::Image;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

#class method
sub get_by_image_id {
    my ($teng, $image_id) = @_;

    return $teng->single(
        'image',
        {
            image_id  => $image_id
        }
    );
}

sub get_by_uploaded_by{
    my ($teng, $uploaded_by, $from, $limit) = @_;

    $limit ||= 10;

    my $sql = <<QUERY;
    SELECT
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

    return \@records;
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

1;
