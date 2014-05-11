package Babyry::Service::Child;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use Data::Dumper;
use List::MoreUtils qw/uniq/;
use Carp;

use Babyry::Service::User;

sub get_child_info_by_image_ids {
    my ($self, $image_ids) = @_;

    my $teng = $self->teng('BABYRY_MAIN_R');
    my ($image_child_list, $child_ids)
        = $self->model('image_child_map')->get_by_image_ids($teng, $image_ids);
    
    return unless $image_child_list && scalar @$image_child_list;

    # TODO modelの返り値をhashに統一したい
    my $child_info = $self->model('child')->get_by_child_ids($teng, $child_ids) or return;

    my %child_info_map = map {
        $_->child_id => { child_id => $_->child_id, child_name => $_->child_name }
    } @$child_info;

    my %ret = ();
    for my $r (@$image_child_list) {
        my $child = $child_info_map{ $r->{child_id} };
        $ret{ $r->{image_id} } ||= [];
        push @{ $ret{ $r->{image_id} } }, $child;
    }
    return \%ret;
}

sub get_related_child_list {
    my ($self, $user_id, $opt) = @_;

    $opt ||= {};

    my $teng = $self->teng('BABYRY_MAIN_R');

    my @relative_ids = keys %{ $self->model('relatives')->get_by_user_id($teng, $user_id) || {} };
    my @target_user_ids = @relative_ids;
    push @target_user_ids, $user_id if ! $opt->{relatives_only};

    # TODO modelの返り値をhashに統一したい
    my $child = $self->model('child')->get_by_created_by($teng, \@target_user_ids) || [];

    # TODO このmethodはService::Imageに移すべきな気がする
    my $icon_image_urls = Babyry::Service::User->new->get_icon_urls(+{
        user_info_list => { map { $_->child_id => +{icon_image_id => $_->icon_image_id} } @$child },
    });

    my @child_info = map {
        +{
            %{$_->get_columns},
            icon_url => $icon_image_urls->{$_->child_id}
        }
    } @$child;

    return \@child_info;
}

1;

