package Babyry::Service::Entry;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use Babyry::Model::Image;
use Babyry::Model::ImageUserMap;
use Babyry::Model::ImageStampMap;
use Babyry::Model::Comment;
use Data::Dump;
use Babyry::Common;

#params
# stamp_id:    int(default: 0)
# uploaded_by: int(default: 0)
# count:       int(default: 10)
# page:        int(default: 1)
# searchの条件は今後増えるかもしれないので、search自体は、dispatchするだけにする。
sub search {
    my ($self, $params) = @_;
    my ($stamp_id, $uploaded_by, $count, $page) = @$params{qw/stamp_id uploaded_by count page/};

    my $teng = $self->teng('BABYRY_MAIN_R');
    my $from = ($page - 1) * $count || 0;

    my ($images, $found_row_count)  = Babyry::Model::ImageUserMap::get_by_user_id($teng, $uploaded_by, $from, $count);

    # imagesを他の経路から取ってきたときも、get_entries_by_imagesを使い回せる用にしておく。
    my $entries = $self->get_entries_by_images($images);
    return {
        entries         => $entries,
        found_row_count => $found_row_count,
    };
}

sub get_entries_by_images{
    my ($self, $images) = @_;
    my $teng = $self->teng('BABYRY_MAIN_R');

    my $image_ids = Babyry::Model::Image::get_image_ids_by_rows($images);
    my $stamps    = Babyry::Model::ImageStampMap::get_by_image_ids($teng, $image_ids);
    #my $stamp_master = TODO
    
    my @entries;

    for my $image(@$images){
        my $columns = $image->get_columns;

        # TODO stampのマスタ−からひっぱてくる。
        # とりあえず、stamp_idのリストを返しとく
        # stamp_idsのリストを$stampsから抜き出して、まとめて取るようにする。
        my $stamps = Babyry::Model::ImageStampMap::get_stamp_ids_by_rows($stamps->{$image->image_id});

        # temporary url
        my $url = $self->get_url_by_image_id($image->image_id);

        # comments
        my $comments = Babyry::Model::Comment::get_by_image_id($teng, $image->image_id, 0, 10);
        my $cmt_array = [];
        for my $cmt (@{$comments}) {
            push @{$cmt_array}, {
                comment_id => $cmt->comment_id,
                image_id => $cmt->image_id,
                comment => $cmt->comment,
                created_at => $cmt->created_at,
                user_id => $cmt->commented_by,
            };
        }

        push(@entries,{
            %$columns,
            stamps => $stamps,
            comments => $cmt_array,
            fullsize_image_url => $url,
        });
    }
    
    return \@entries;
}

sub get_url_by_image_id {
    my ($self, $id) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');
    my $url = Babyry::Model::Image->new()->get_by_image_id($teng, $id);

    return $url->url;
}

1;
