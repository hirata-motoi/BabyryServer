#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../../lib');
# temp
$ENV{APP_ENV} = "development";

use Log::Minimal;
use AWS::CLIWrapper;

use Babyry::Logic::Image;

my $aws = AWS::CLIWrapper->new();

my $BUCKET = 'bebyry-image-upload';
my $QUEUE_DIR = '/data/image/uploaded';
my $IMAGE_DIR = '/var/www/html/tmp_uploaded_image';

while(1) {
    opendir my $dh, $QUEUE_DIR or die "$!:$QUEUE_DIR";
    while (my $file = readdir $dh) {
        next if ($file =~ /^\./);
        next if ($file !~ /^(\d+)_([^\s]+)$/);
        my $image_id = $1;
        my $image_prefix = $2;
        my @image_path = `ls $IMAGE_DIR/${image_prefix}*`;
        
	for my $path (@image_path) {
            chomp($path);
            infof("send $path, image_id $image_id");
            next unless ($path =~ /$image_prefix([^\s]+)$/);
            my $s3_name = $image_id . $1;
            &send_to_s3($path, $s3_name, "$QUEUE_DIR/$file");
        }
    }
    closedir $dh;
    sleep 1;
}

sub send_to_s3 {
    my $path = shift;
    my $file = shift;
    my $queue_file = shift;
    
    my $params = +{
        body => $path,
        key => $file,
        bucket => $BUCKET,
    };
    my $res = $aws->s3api('put-object', $params);
    if (!$res) {
        warnf( $AWS::CLIWrapper::Error->{Code});
        warnf( $AWS::CLIWrapper::Error->{Message});
        return;
    }

    my $local_size = -s $path;
    my $s3_size = 0;
    $params = +{
        prefix => $file,
        bucket => $BUCKET,
    };
    $res = $aws->s3api('list-objects', $params);
    if($res) {
        $s3_size = $res->{Contents}[0]->{Size};
        if($local_size == $s3_size) {
            unlink($path);
            unlink($queue_file);
        }
    } else {
        warnf( $AWS::CLIWrapper::Error->{Code});
        warnf( $AWS::CLIWrapper::Error->{Message});
    }
    return;
}
