package Babyry::Model::Comment;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

sub add {
    my ($self, $teng, $params) = @_;

    return $teng->insert(
        'comment',
        {
            comment_id   => $params->{comment_id},
            image_id     => $params->{image_id},
            comment      => $params->{comment},
            created_at   => $params->{created_at},
            updated_at   => $params->{updated_at},
            commented_by => $params->{user_id},
        }
    );
}

sub get_by_image_id {
    my ($teng, $image_id, $from, $limit) = @_;

my $sql = <<QUERY;
    SELECT
        *
    FROM
        comment
    WHERE
        image_id = ?
    ORDER BY
        created_at DESC
    LIMIT ?, ?
QUERY
    my @records =$teng->search_by_sql(
        $sql,
        [$image_id, $from, $limit]
    );

    return \@records;
}


1;
