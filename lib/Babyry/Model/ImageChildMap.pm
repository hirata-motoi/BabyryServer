package Babyry::Model::ImageChildMap;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

use Log::Minimal;

sub attach {
    my ($self, $teng, $params) = @_;

    # insert ignoreの結果が知りたいためstatement handleを保持する
    my ($stmt, @bind) = $self->maker->insert_multi(
        'image_child_map',
        [
            {
                image_id   => $params->{image_id},
                child_id   => $params->{child_id},
                disabled   => 0,
                created_at => $params->{created_at} || time,
                updated_at => $params->{updated_at} || time,
            },
        ],
        {
            update => {
                disabled   => 0,
                updated_at => $params->{updated_at} || time,
            }
        }
    );
    my $sth = $teng->dbh->prepare($stmt);
    $sth->execute(@bind);

    return $sth->rows;
}

sub detach {
    my ($self, $teng, $params) = @_;

    my $updated_row_count = $teng->update(
        'image_child_map',
        {
            disabled   => 1,
            updated_at => $params->{updated_at} || time,
        },
        {
            image_id   => $params->{image_id},
            child_id   => $params->{child_id},
        },
    );

    return $updated_row_count;
}

sub get_by_image_ids {
    my ($self, $teng, $image_ids) = @_;

    return unless $image_ids && ref $image_ids eq 'ARRAY' && scalar @$image_ids;

    my $itr = $teng->search(
        'image_child_map',
        {
            image_id => $image_ids,
            disabled => 0,
        }
    );

    my (@image_child_list, @child_ids);
    while ( my $r = $itr->next ) {
        push @image_child_list, {
            child_id => $r->child_id,
            image_id => $r->image_id
        };
        push @child_ids, $r->child_id;
    }
    return (\@image_child_list, \@child_ids);
}

1;

