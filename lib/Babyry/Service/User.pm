package Babyry::Service::User;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Service::Base/;
use Log::Minimal;

#sub get_icon_urls_by_user_ids {

# icon_urlを取得
# user_info_list(get_by_user_idsの結果)とuser_idsどちらをparamに入れてもOK
# 両方あった場合はuser_info_listが優先される
# TODO というかuser_info_listはarrayではない！！！
sub get_icon_urls {
    my ($self, $params) = @_;

    return if (!$params->{user_ids} && !$params->{user_info_list});
    return if $params->{user_ids} && ! scalar @{$params->{user_ids}};
    if ($params->{user_info_list}) {
        return if ! $params->{user_info_list};
        return if ref $params->{user_info_list} ne 'HASH';
        return if ! keys %{$params->{user_info_list}};
    }

    my $teng = $self->teng('BABYRY_MAIN_R');
    my $users = $params->{user_info_list} || $self->model('user')->get_by_user_ids($teng, $params->{user_ids});

    my $images = $self->model('image')->get_by_image_ids(
        $teng,
        [ map { $users->{$_}{icon_image_id} } keys %$users ]
    ) || {};

    my $default_user_icon_url = Babyry::Common->config->{default_user_icon_url};
    my %icon_urls = ();
    for my $user_id (keys %$users) {

        my $icon_url = _icon_url($user_id, $users, $images) || $default_user_icon_url;

        $icon_urls{$user_id} =  $icon_url;
    }
    return \%icon_urls;
}

sub _icon_url {
    my ($user_id, $users, $images) = @_;

    my $icon_image_id = $users->{$user_id}{icon_image_id} or return;
    my $icon_image = $images->{$icon_image_id} or return;
    $icon_image->{url};
}

1;

