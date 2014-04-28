package Babyry::Model::ImageFile;

use strict;
use warnings;
use parent qw/Babyry::Model::Base/;
use Babyry;
use Babyry::Common;

use Log::Minimal;
use File::Spec;
use Image::Info qw/image_type/;
use Class::Load qw/load_class/;
use String::CamelCase qw/camelize/;
use Carp;

sub factory {
    my ($class, $params) = @_;

    my $format = lc( (image_type($params->{path}) || {})->{file_type} || '');

    croak sprintf('Invalid file type : %s', $params->{path})
        if ! grep { $format eq $_ } @{ Babyry::Common->config->{allowed_image_format} };

    my $class_name = sprintf 'Babyry::Model::ImageFile::%s', camelize($format);
    load_class($class_name);

    return $class_name->new(+{
        %$params,
        format => $format
    });
}

sub write {
    my ($self, %params) = @_;

    $self->{img}->write(%params) or croak($self->img->errstr);
}

sub write_with_scale {
    my ($self, %params) = @_;

    my $file   = delete $params{file};
    my $scaled = $self->{img}->scale(%params);
    $scaled->write(file => $file) or croak($scaled->errstr);

    return $scaled;
}


1;
