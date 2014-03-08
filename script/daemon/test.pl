#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../../lib');
# temp
$ENV{APP_ENV} = "development";

use Log::Minimal;
use Data::Dumper;

use Babyry::Common;
#use Babyry::Service::Base;

my $TMP_BUCKET = Babyry::Common->config->{'tmp_bucket'};
print "$TMP_BUCKET\n";
