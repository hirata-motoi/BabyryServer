#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../../lib');

use Log::Minimal;
use Data::Dumper;
use Getopt::Long;

use Babyry::Common;
use Babyry::Model::WithdrawQueue;
use Babyry::Model::Image;
use Babyry::Model::ImageUserMap;

GetOptions(
    'env|e=s' => \my $env,
);
$ENV{APP_ENV} ||= ($env || 'developmemt');

require Babyry::Service::Base;
my $teng = Babyry::Service::Base->new()->teng('BABYRY_MAIN_W');
my $teng_r = Babyry::Service::Base->new()->teng('BABYRY_MAIN_R');
my $withdraw_queue = Babyry::Model::WithdrawQueue->new();
my $image = Babyry::Model::Image->new();
my $image_user_map = Babyry::Model::ImageUserMap->new();
while(1) {
    my $queue = $withdraw_queue->dequeue($teng_r);
    for (@{$queue}) {
        my $user_id = $_->user_id;
        print "$user_id\n";
        while(1) {
            my @image_ids = $image->get_by_uploaded_by($teng_r, $user_id, 0, 10);
            for my $img (@{$image_ids[0]}) {
                print $img->image_id . "\n";
            }
            sleep 1;
        }
    }
    sleep 1;
}


