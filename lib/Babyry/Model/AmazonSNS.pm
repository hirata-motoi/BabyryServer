package Babyry::Model::AmazonSNS;
use strict;
use warnings;
use utf8;

use Log::Minimal;
use AWS::CLIWrapper;

use parent qw/Babyry::Model::Base/;

sub set_endpoint {
    my ($self, $params) = @_;
    my $aws = AWS::CLIWrapper->new(
        region => 'ap-northeast-1',
    );
    my $params = {
        'platform-application-arn' => 'arn:aws:sns:ap-northeast-1:823613481556:app/APNS_SANDBOX/babyrydevtest',
        'token' => $params->{'devicetoken'},
        'custom-user-data' => $params->{'user_id'},
    };
    my $res = $aws->sns('create-platform-endpoint', $params);
    if($AWS::CLIWrapper::Error->{Code}) {
        infof("$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}");
        return;
    }
    return $res;
}

1;
