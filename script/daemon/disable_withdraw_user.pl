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
use Babyry::Model::ImageDeleteQueue;

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
my $image_delete_queue = Babyry::Model::ImageDeleteQueue->new();
while(1) {
    my $queue = $withdraw_queue->dequeue($teng_r);
    for (@{$queue}) {
        my $user_id = $_->user_id;
        print "withdraw user : $user_id\n";
        while(1) {
            my @image_ids = $image->get_by_uploaded_by($teng_r, $user_id, 0, 10);
            last if (!scalar(@{$image_ids[0]}));
            $teng->txn_begin;
            for my $img (@{$image_ids[0]}) {
                print "remove image : " . $img->image_id . "\n";
                $image->remove($teng, $img->image_id);
                $image_delete_queue->enqueue($teng, $img->image_id);
                $image_user_map->make_disable($teng, {image_id => $img->image_id});
            }
            $teng->txn_commit;
            sleep 1;
        }
        $teng->txn_begin;
        $withdraw_queue->delete_queue_by_id($teng, $user_id);
        $teng->txn_commit;
    }
    sleep 1;
}


