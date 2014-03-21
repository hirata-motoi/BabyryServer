package Babyry::Model::Base;

use strict;
use warnings;
use utf8;
use parent qw/Class::Accessor::Fast/;

sub escape4like {
    my ($self, $str) = @_;
    $str =~ s/\\/\\\\/g;
    $str =~ s/%/\\%/g;
    $str =~ s/_/\\_/g;
    return $str;
}

1;

