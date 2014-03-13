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

sub detach {
    my ($self, $image_id, $stamp_id) = @_;

    my $teng  = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;

    my $row_num = Babyry::Model::ImageStampMap::delete($teng, $image_id, $stamp_id);
    $teng->txn_commit;

    return $row_num;
}

sub list {
    my ($self, $user_id) = @_;

    my $teng       = $self->teng('BABYRY_MAIN_R');
    my $stamp      = $self->model('stamp');

    # TODO 自分のrelativesが保持しているstampのリストも返す
    my $stamps = $stamp->get($teng);

    # 各stampが何枚の写真にattachされているかを取得
    # 自分が閲覧可能なstampのみ対象
    my $image_count_by_stamp = $self->_get_image_count_by_stamp($teng, $user_id);

    # 各stampのデータ
    my $stamp_detail =  $stamp->get_details_by_ids($teng, [ map { $_->{stamp_id} } @$stamps ]);

    # データをmerge
    my @ret = map {
        +{
            %$_,
            attached_count => $image_count_by_stamp->{ $_->{stamp_id} } || 0
        }
    } @$stamp_detail;

    return \@ret;
}

sub _get_image_count_by_stamp {
    my ($self, $teng, $user_id) = @_;

    my $image_user = $self->model('image_user_map');
    my $image_ids = $image_user->get_image_ids_by_user_id($teng, $user_id);
    my $image_stamp_map = Babyry::Model::ImageStampMap::get_by_image_ids($teng, $image_ids);

    my %image_count_by_stamp = ();
    for my $image_id ( keys %{$image_stamp_map} ) {
        map { $image_count_by_stamp{ $_->stamp_id }++ } @{ $image_stamp_map->{$image_id} };
    }
    return \%image_count_by_stamp;
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

