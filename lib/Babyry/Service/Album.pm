package Babyry::Service::Album;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Log::Minimal;
use Data::Dump;
use Babyry::Common;

sub search {
    my ($self, $params) = @_;

    my $teng_r = $self->teng('BABYRY_MAIN_R');
    my $user_album_map = $self->model('UserAlbumMap');
    my $child = $self->model('Child');
    my $user = $self->model('User');
    my $album_ids = $user_album_map->get_by_user_id($teng_r, $params);
    my $album_attr = $self->model('AlbumAttribute');
    my @album_detail;
    for my $album_id (@{$album_ids}) {
        #push @album_detail, $album_attr->get_by_album_id($teng_r, {album_id => $album_id});
        my $_album_detail = ();
        my $_attr = $album_attr->get_by_album_id($teng_r, {album_id => $album_id});

        $_album_detail->{'album_id'} = $album_id;
        for (keys %{$_attr}) {
            if ($_ eq 'child_ids') {
                my $child_data = $child->get_by_child_ids($teng_r, $_attr->{child_ids});
                my @_child_data = ();
                for ( keys %{$child_data}) {
                    push @_child_data, {
                        child_id => $child_data->{$_}->{child_id},
                        child_name => $child_data->{$_}->{child_name},
                    }
                }
                $_album_detail->{$_} = $_attr->{child_ids};
                $_album_detail->{'child_data'} = \@_child_data;
            } elsif ($_ eq 'relative_ids') {
                my $relative_data = $user->get_by_user_ids($teng_r, $_attr->{relative_ids});
                my @_relative_data = ();
                for ( keys %{$relative_data}) {
                    push @_relative_data, {
                        relative_id => $relative_data->{$_}->{user_id},
                        relative_name => $relative_data->{$_}->{user_name},
                    }
                }
                $_album_detail->{$_} = $_attr->{relative_ids};
                $_album_detail->{'relative_data'} = \@_relative_data;
            } else {
                $_album_detail->{$_} = $_attr->{$_};
            }
        }
        push @album_detail, $_album_detail;
    }
    return {album_attribute => \@album_detail};
}

sub add_attr {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    my $album_attribute = $self->model('AlbumAttribute');
    $album_attribute->add($teng, $params);
    $teng->txn_commit;
    $teng->disconnect();

    return {};
}

sub edit_name {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    my $album_attribute = $self->model('AlbumAttribute');
    $album_attribute->edit_name($teng, $params);
    $teng->txn_commit;
    $teng->disconnect();

    return {};
}

sub delete_attr {
    my ($self, $params) = @_;

    my $teng = $self->teng('BABYRY_MAIN_W');
    $teng->txn_begin;
    my $album_attribute = $self->model('AlbumAttribute');
    my $res = $album_attribute->delete_attr($teng, $params);
    $teng->txn_commit;
    $teng->disconnect();

    return {res => $res};
}

1;
