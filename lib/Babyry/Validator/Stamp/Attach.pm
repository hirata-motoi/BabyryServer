package Babyry::Validator::Stamp::Attach;

use strict;
use warnings;
use parent qw/Babyry::Validator/;

use Babyry::Service::Image;
use Babyry::Service::Stamp;

sub form_validator_conf {
    +{
        image_id => [qw/NOT_NULL INT/],
        stamp_id => [qw/NOT_NULL INT/],
    };
}

sub do_logic_validate {
    my ($self, $c, $validator) = @_;

    my $image_id = $c->req->param('image_id') || 0;
    my $stamp_id = $c->req->param('stamp_id') || 0;
    my $user_id  = $c->stash->{user_id}       || 0;

    my $image = Babyry::Service::Image->new;
    my $stamp = Babyry::Service::Stamp->new;

    # image_idの存在チェック
    $validator->set_error(image_id => 'NOT_EXISTS')
        if ! $image->is_valid_image_id($image_id);

    # imageへのアクセス権限
    $validator->set_error(image_id => 'AUTHORIZATION')
        if ! $image->has_authorization($user_id, $image_id);

    # stampの存在チェック
    $validator->set_error(stamp_id => 'NOT_EXISTS')
        if ! $stamp->get($stamp_id)->{stamp_id};

    # 既にstampされているか
    $validator->set_error(stamp_id => 'ATTACHED')
        if $stamp->exists_image_stamp_map($image_id, $stamp_id);
}

1;

