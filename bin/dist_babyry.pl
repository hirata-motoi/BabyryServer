#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Log::Minimal;

my $config = do ('/home/babyry/BabyryServer/config/prod-server.conf');

my $localhost = `hostname`;
chomp($localhost);

die 'this is not dist host' if ($localhost ne $config->{servers}->{dist});

my $command = '/usr/bin/rsync';
my $option = '-av';
my $exclude = '--exclude=log --exclude=supervise';
my $dryrun = '-n';

my $exec_command = "$command $option $exclude";
$exec_command .= " $dryrun" if ($ARGV[0] ne 'exec');

my @dist_dir = ('BabyryServer', 'aws', 'git', 'perl5', '.rbenv');

for my $host (@{$config->{servers}->{web}}) {
    for my $dir (@dist_dir) {
        my $rsync_command = "$exec_command /home/babyry/$dir $host:/home/babyry";
        my $res = `sudo $rsync_command`;
        print "$res\n";
    }
}

