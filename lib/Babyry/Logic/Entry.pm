package Babyry::Logic::Entry;
use strict;
use warnings;
use utf8;
use parent qw/Babyry::Logic/;

use Babyry::Service::Entry;

#params
# stamp_id:    int(default: 0)
# uploaded_by: int(default: 0)
# count:       int(default: 10)
# page:        int(default: 1)

sub search {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Entry->new;
    return $service->search($params);
}

1;
