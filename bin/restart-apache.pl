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
    my $res = `sudo ssh $host /etc/init.d/httpd $ARGV[0]`;
    print "$res\n";
}

