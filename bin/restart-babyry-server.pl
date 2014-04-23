#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Log::Minimal;

my $config = do ('/home/babyry/BabyryServer/config/prod-server.conf');

my $localhost = `hostname`;
chomp($localhost);

die 'this is not dist host' if ($localhost ne $config->{servers}->{dist});
die 'there is no option' if (!$ARGV[0]);

for my $host (@{$config->{servers}->{web}}) {
    print "$host\n";
    my $res;
    if ($ARGV[0] eq 'status') {
        $res = `sudo ssh $host svstat /service/babyry-server/`;
    } elsif ($ARGV[0] eq 'reload') {
        $res = `sudo ssh $host svc -h /service/babyry-server/`;
    } elsif ($ARGV[0] eq 'restart') {
        $res = `sudo ssh $host svc -t /service/babyry-server/`;
    } elsif ($ARGV[0] eq 'stop') {
        $res = `sudo ssh $host svc -d /service/babyry-server/`;
    } elsif ($ARGV[0] eq 'start') {
        $res = `sudo ssh $host svc -u /service/babyry-server/`;
    }
    print "$res\n";
}

