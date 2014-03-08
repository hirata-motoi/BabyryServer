package Babyry::Model::TempImageUpload;

use strict;
use warnings;
use parent qw/Babyry::Model::Base/;
use Babyry;
use Log::Minimal;
use File::Spec;
use Imager::ExifOrientation;
use Image::Info qw/image_type/;
use Babyry::Common;
use Babyry::Model::UploadS3;

sub make_thumbnail {
    my ($self, $params) = @_;

    my $format = lc( (image_type($params->{path}) || {})->{file_type} || '');

    croakf('Invalid file type : %s', $params->{path})
        if ! grep { $format eq $_ } @{ Babyry::Common->config->{allowed_image_format} };

    my $img = Imager::ExifOrientation->rotate( path => $params->{path} )
        or return { error1 => "Can't read $params->{path}", path => $params->{path} };

    my $time    = time();
    my $user_id = $params->{user_id};
    my $tmpdir  = Babyry::Common->config->{tmp_uploaded_image_dir};
    # TODO define config or %ENV
    if ($tmpdir !~ m|^/|) {
        $tmpdir = File::Spec->catdir( Babyry->base_dir, $tmpdir );
    }

    # synthesize fullsize image
    my $image_name = sprintf('%d_%d.%s', $user_id, $time, $format);
    $img->write(
        file => File::Spec->catfile( $tmpdir, $image_name ),
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

    my $s3 = Babyry::Model::UploadS3->new()->tmp_upload($tmpdir, [$image_name, $thumb_name]);
    my $tmp_url = 'https://babyry-image-tmp-upload-dev.s3.amazonaws.com/'.$thumb_name;

    return {
        image_tmp_name => $thumb_name,
        image_tmp_url  => $tmp_url,
        size => {
            x => $thumb->getwidth(),
            y => $thumb->getheight(),
        },
    };
}

1;
