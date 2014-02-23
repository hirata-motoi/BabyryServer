package Babyry::Service::Stamp;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;
use Babyry::Model::ImageStampMap;

sub attach {
    my ($self, $image_id, $stamp_id) = @_;

    my $teng  = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;

    my $ret = Babyry::Model::ImageStampMap::create($teng, $image_id, $stamp_id);
    $teng->txn_commit;

    return $ret;
}

sub get {
    my ($self, $stamp_id) = @_;

    my $model = $self->model('stamp');
    my $teng  = $self->teng('BABYRY_MAIN_R');

    return $model->get_by_id($teng, $stamp_id) || {};
}

sub exists_image_stamp_map {
    my ($self, $image_id, $stamp_id) = @_;

    my $teng  = $self->teng('BABYRY_MAIN_R');
    my $map = Babyry::Model::ImageStampMap::get_by_image_ids($teng, [ $image_id ]);

    return ( grep { $_->stamp_id == $stamp_id } @{ $map->{$image_id} || [] } )
        ? 1 : 0;
}


1;

