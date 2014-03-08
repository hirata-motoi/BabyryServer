package Babyry::Model::Image;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

#class method
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

sub get_by_uploaded_by{
    my ($teng, $uploaded_by, $from, $limit) = @_;

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
    my $row = $teng->dbh->selectrow_array(q{ SELECT FOUND_ROWS() });

    return (\@records, $row);
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
        }
    );
}

1;
