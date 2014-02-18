package Babyry::Model::TempImageUpload;

use strict;
use warnings;
use Imager;
use parent qw/Babyry::Model::Base/;
use Log::Minimal;

sub make_thumbnail {
    my ($self, $params) = @_;

    my $img = Imager->new;
    $img->read(file => $params->{path}) or return { error1 => $img->errstr, path => $params->{path} };
    my $time = time();
    my $user_id = $params->{user_id};

    my $thumb;
    if ($params->{path} =~ m{\.(jpg|jpeg)$}) {
        $img->write(file => "/var/www/html/tmp_uploaded_image/${user_id}_${time}.jpg", jpegquality => 60) or return { error2 => $img->errstr };
        $thumb = $img->scale(
            xpixels => 40,
            ypixels => 40,
            type    => 'max',
        );
        $thumb->write(file => "/var/www/html/tmp_uploaded_image/${user_id}_${time}_thumb.jpg") or return { error3 => $thumb->errstr };
    }

    return {
        image_tmp_name => "${user_id}_${time}_thumb.jpg",
        image_tmp_url => "http://babyryserver5001/tmp_uploaded_image/${user_id}_${time}_thumb.jpg",
        size => {
            x => $thumb->getwidth(),
            y => $thumb->getheight(),
        },
    };
}

1;
