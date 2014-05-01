package Babyry::Model::TempImageUpload;

use strict;
use warnings;
use parent qw/Babyry::Model::Base/;
use Babyry;
use Babyry::Common;
use Babyry::Model::UploadS3;

use Log::Minimal;
use File::Spec;
use Imager::ExifOrientation;
use Image::Info qw/image_type/;

sub make_thumbnail {
    my ($self, $img, $params) = @_;

    my $format = lc( (image_type($params->{path}) || {})->{file_type} || '');

    croak('Invalid file type : %s', $params->{path})
        if ! grep { $format eq $_ } @{ Babyry::Common->config->{allowed_image_format} };

    my $time    = time();
    my $user_id = $params->{user_id};
    my $tmpdir  = Babyry::Common->config->{tmp_uploaded_image_dir};
    # TODO define config or %ENV
    if ($tmpdir !~ m|^/|) {
        $tmpdir = File::Spec->catdir( Babyry->base_dir, $tmpdir );
    }

    # synthesize fullsize image
    my $image_name = sprintf('%d_%d.%s', $user_id, $time, $format);
    my $img_raw_size = -s $params->{path};

    # 400K以下の画像であればそのまま処理
    # 実際にはqualityが75%なので225Kくらいになる。正確なサイズは画像による
    if ($img_raw_size < 400000) {
        $img->write(
            file => File::Spec->catfile( $tmpdir, $image_name ),
        );
    # 400K以上の場合には、大きさを小さくしてだいたい200Kくらいになるようにスケールさせる
    # (200K / 画像サイズ) = 縮小率の2乗  的な計算をしている
    } else {
        my $long_side = ($img->getwidth() > $img->getheight()) ? $img->getwidth() : $img->getheight();
        my $img_scale = int($long_side * sqrt(200000/$img_raw_size));
        $img->write_with_scale(
            xpixels => $img_scale,
            ypixels => $img_scale,
            type    => 'max',
            file => File::Spec->catfile( $tmpdir, $image_name ),
        );
    }

    # synthesize thumbnail
    my $thumb_name = sprintf('%d_%d_thumb.%s', $user_id, $time, $format);
    my $thumb_path = File::Spec->catfile( $tmpdir, $thumb_name );
    my $thumb = $img->write_with_scale(
        xpixels => 160,
        ypixels => 160,
        type    => 'max',
        file    => $thumb_path,
    );

    my $s3 = Babyry::Model::UploadS3->new()->tmp_upload($tmpdir, [$image_name, $thumb_name]);
    my $tmp_url = 'https://' . Babyry::Common->config->{tmp_bucket} . '.s3.amazonaws.com/'.$thumb_name;

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
