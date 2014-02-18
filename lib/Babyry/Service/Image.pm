package Babyry::Service::Image;

use strict;
use warnings;
use utf8;
use parent qw/Babyry::Service::Base/;
use Babyry::Model::TempImageUpload;
use Log::Minimal;

sub web_upload {
    my ($self, $params) = @_;

    # make thumbnail
    my $model = Babyry::Model::TempImageUpload->new;
    my $ret = $model->make_thumbnail($params);

    return $ret;
}

1;

