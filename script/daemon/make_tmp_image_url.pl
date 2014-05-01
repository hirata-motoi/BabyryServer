#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../../lib');

use Log::Minimal;
use AWS::CLIWrapper;
use Data::Dumper;
use Getopt::Long;

use Babyry::Common;
use Babyry::Model::ImageQueue;
use Babyry::Model::Image;

GetOptions(
    'env|e=s' => \my $env,
);
$ENV{APP_ENV} ||= ($env || 'development');

my $aws = AWS::CLIWrapper->new();

my $BUCKET = Babyry::Common->config->{bucket};
my $RUBY = Babyry::Common->config->{ruby};
my $HOME_DIR = Babyry->base_dir;

require Babyry::Service::Base;
my $teng = Babyry::Service::Base->new()->teng('BABYRY_MAIN_W');
my $teng_r = Babyry::Service::Base->new()->teng('BABYRY_MAIN_R');
my $image = Babyry::Model::Image->new();
while(1) {
    my $old_update = time() - 24*60*60;
    my $images = $image->get_image_by_updated_at($teng_r, $old_update);
    my $urls = {};
    my $unixtime = time();
    for (@{$images}) {
        my $image_id = $_->image_id;
        my $user_id = $_->uploaded_by;
        my $format = $_->format;
        my $image_name = "${user_id}\/${image_id}\.${format}";
        $urls->{$image_id} = get_tmp_image_url($image_name);
    }
    eval {
        $teng->txn_begin;
        for my $id (keys %{$urls}) {
            $image->update_url($teng, $id, $urls->{$id}, $unixtime);
        }
        $teng->txn_commit;
    };
    print "$@\n" if ($@);

    sleep 1;
}

sub get_tmp_image_url {
    my $image_name = shift;
    my $command  = "$RUBY $HOME_DIR/lib/Babyry/Model/get_onetime_url.rb $BUCKET $image_name";
    my $url = `$command`;
    chomp($url);
    print "$image_name $url\n";
    return $url;
}

