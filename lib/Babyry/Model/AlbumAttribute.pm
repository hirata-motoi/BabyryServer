package Babyry::Model::AlbumAttribute;

use strict;
use warnings;
use utf8;

use parent qw/Babyry::Model::Base/;
use Babyry::Model::Child;
use Babyry::Model::User;
use Data::Dumper;
use Log::Minimal;

sub get_by_album_id {
    my ($self, $teng, $params) = @_;

    my $res = $teng->search(
        'album_attribute',
        {
            album_id  => $params->{album_id},
        }
    );

    my %attribute = ();
    my @child_ids = ();
    my @relative_ids = ();
    while ( my $r = $res->next ) {
        # child_idの場合は配列に突っ込む
        if ($r->attr_key eq "child_id") {
            push @child_ids, $r->attr_value;
        # relative_idの場合は配列に突っ込む
        } elsif ($r->attr_key eq "relative_id") {
            push @relative_ids, $r->attr_value;
        } else {
            $attribute{$r->attr_key} = $r->attr_value;
        }
    }

    $attribute{child_ids} = \@child_ids;
    $attribute{relative_ids} = \@relative_ids;

    return \%attribute;
}

sub add {
    my ($self, $teng, $params) = @_;

    return if (!$params->{'key'} or !$params->{'attr'});
    my $key_str = $params->{'key'} . "";
    my $val_str = $params->{'attr'} . "";
    $teng->insert(
       'album_attribute',
       {
           album_id   => $params->{'album_id'},
           attr_key   => $key_str,
           attr_value => $val_str,
       }
    );

    return;
}

sub edit_name {
    my ($self, $teng, $params) = @_;

     $teng->update(
        'album_attribute',
        {
            attr_value => $params->{'album_name'},
        },
        {
            album_id   => $params->{'album_id'},
            attr_key   => 'name',
        }
    );

    return;
}

sub delete_attr {
    my ($self, $teng, $params) = @_;

    infof(Dumper $params);
    $teng->delete(
        'album_attribute',
        {
            album_id   => $params->{'album_id'},
            attr_key   => $params->{'attr_key'},
            attr_value => $params->{'attr_value'},
        }
    );

    return;
}

1;
