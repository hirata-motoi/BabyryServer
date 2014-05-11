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

GetOptions(
    'env|e=s' => \my $env,
);
$ENV{APP_ENV} ||= ($env || 'developmemt');


my $aws = AWS::CLIWrapper->new();

my $TMP_BUCKET = Babyry::Common->config->{'tmp_bucket'};
my $TRASH_BUCKET = Babyry::Common->config->{'trash_bucket'};
my %EXPIRE_DAY;
$EXPIRE_DAY{$TMP_BUCKET} = Babyry::Common->config->{'tmp_bucket_expire_day'};
$EXPIRE_DAY{$TRASH_BUCKET} = Babyry::Common->config->{'trash_bucket_expire_day'};

while(1) {
    for my $bucket ($TMP_BUCKET, $TRASH_BUCKET) {
        my ($day,$mon,$year) = (localtime(time - 60 * 60 * 24 * $EXPIRE_DAY{$bucket}))[3..5];
        $year += 1900;
        $mon += 1;
        my $expire = $year . sprintf("%02d", $mon) . sprintf("%02d", $day);
        my $params = {
            bucket => $bucket,
        };
        my $res = $aws->s3api('list-objects', $params);
        if (!$res) {
            critf("$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}");
        } else {
            for my $img (@{$res->{'Contents'}}) {
                if ($img->{'LastModified'} =~ /^(\d\d\d\d)-(\d\d)-(\d\d)/) {
                    my $lastmodified = $1 . $2 . $3;
                    if ($expire > $lastmodified) {
                        my $params2 = {
                            bucket => $bucket,
                            key    => $img->{'Key'},
                        };
                        my $res2 = $aws->s3api('delete-object', $params2);
                        if (!$res2) {
                            critf("$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}");
                        } else {
                            print "deleted : " . $bucket . " " . $img->{'Key'} . " " . $img->{'LastModified'} . "\n";
                        }
                    }
                }
            }
        }
    }
    sleep 60 * 60 * 24;
}

