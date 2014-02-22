package Babyry::Model::TempImageUpload;

use strict;
use warnings;
use parent qw/Babyry::Model::Base/;
use Babyry;
use Log::Minimal;
use File::Spec;
use Imager;
use Image::Info qw/image_type/;
use Babyry::Common;



sub make_thumbnail {
    my ($self, $params) = @_;

    my $format = lc( (image_type($params->{path}) || {})->{file_type} || '');

    croakf('Invalid file type : %s', $params->{path})
        if ! grep { $format eq $_ } @{ Babyry::Common->config->{allowed_image_format} };

    my $img = Imager->new;
    $img->read(file => $params->{path}) or return { error1 => $img->errstr, path => $params->{path} };

    my $time    = time();
    my $user_id = $params->{user_id};
    my $tmpdir  = Babyry::Common->config->{tmp_uploaded_image_dir};
    # TODO define config or %ENV
    if ($tmpdir !~ m|^/|) {
        $tmpdir = File::Spec->catdir( Babyry->base_dir, $tmpdir );
    }


    # synthesize fullsize image
    $img->write(
        file => File::Spec->catfile(
            $tmpdir, sprintf('%d_%d.%s', $user_id, $time, $format)
        ),
        jpegquality => 60
    ) or return { error2 => $img->errstr };

    # synthesize thumbnail
    my $thumb_name = sprintf('%d_%d_thumb.%s', $user_id, $time, $format);
    my $thumb_path = File::Spec->catfile( $tmpdir, $thumb_name );
    my $thumb      = $img->scale(
        xpixels => 160,
        ypixels => 160,
        type    => 'max',
    );
    $thumb->write( file => $thumb_path ) or return { error3 => $thumb->errstr };

    return {
        image_tmp_name => $thumb_name,
        image_tmp_url  => File::Spec->catfile(
            Babyry::Common->config->{tmp_uploaded_image_relative_path},
            $thumb_name
        ),
        size => {
            x => $thumb->getwidth(),
            y => $thumb->getheight(),
        },
    };
}

1;
