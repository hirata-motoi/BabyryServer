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
use JSON;

use Babyry::Common;

GetOptions(
    'env|e=s' => \my $env,
);
$ENV{APP_ENV} ||= ($env || 'developmemt');


my $aws = AWS::CLIWrapper->new(
    region => "ap-northeast-1",
);

my $arn = 'arn:aws:sns:ap-northeast-1:823613481556:endpoint/APNS_SANDBOX/babyrydevtest/d8767b85-bd54-361d-b1b1-66d280ff56f1';
&send_notification($arn);

sub send_notification {
    my $arn = shift;

    my $message_body = encode_json({
        aps => {
            'alert' => 'message',
            'badge' => 0,
            'sound' => 'default'
        }
    });
    my $message = {
        "APNS_SANDBOX" => $message_body
    };

    my $params = {
        'target-arn' => $arn,
        'message-structure' => 'json',
        'message' => $message
    };

    my $res = $aws->sns('publish', $params);
    if(!$res) {
        critf("$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}");
    } else {
        infof($res);
    }
}


