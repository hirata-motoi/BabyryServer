package Babyry::Model::ImageStampMap;

use parent qw/Babyry::Model::Base/;

use strict;
use warnings;
use utf8;

use Data::Dump qw/dump/;

#class method
# {
#       1 => [$row, $row],
#       2 => [$row]
# }
#形式にする。
sub get_by_image_ids{
    my ($teng, $image_ids) = @_;
    return {} if(!$image_ids || ref($image_ids) ne "ARRAY" || !scalar(@$image_ids));

    my @rows =  $teng->search(
        'image_stamp_map',
        {
            image_id => $image_ids
        }
    );

    # 初期化
    # 上記クエリで引っかからなくても、[]は作る。
    my $ret_val;
    for my $image_id (@$image_ids){
        $ret_val->{$image_id} = [];
    }

    for my $row (@rows){
        push(@{$ret_val->{$row->image_id}}, $row);
    }

    return $ret_val;
}

sub get_stamp_ids_by_rows{
    my($rows) = @_;
    my ($rows) = @_;
    return [] if (!$rows || ref($rows) ne "ARRAY" || !scalar(@$rows));

    my @stamp_ids;
    for my $row (@$rows){
        push(@stamp_ids, $row->stamp_id) if($row->stamp_id);
    }

    return \@stamp_ids;
}

1;
