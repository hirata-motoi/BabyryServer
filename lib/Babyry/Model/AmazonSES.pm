package Babyry::Model::AmazonSES;
use strict;
use warnings;
use utf8;

use Log::Minimal;
use AWS::CLIWrapper;
use Jcode;

use parent qw/Babyry::Model::Base/;

sub set_subject {
    my ($self, $subject) = @_;
    $self->{subject} = $subject;
}

sub set_body {
    my ($self, $msg) = @_;
    $self->{body} = $msg;
}

sub set_address {
    my ($self, $address) = @_;
    $self->{address} = $address;
}

sub send_mail {
    my ($self) = @_;
    die 'there is no subject or body or address.' if (!$self->{body} || !$self->{address} || !$self->{subject});

    my $aws = AWS::CLIWrapper->new(
        region => 'us-east-1',
    );

    my $mail_subject = jcode($self->{subject})->jis;
    $mail_subject = jcode($mail_subject)->mime_encode;
    my $mail_to = jcode($self->{address})->jis;
    $mail_to = jcode($mail_to)->mime_encode;
    my $mail_from = jcode('meaning.sys@gmail.com')->jis;
    $mail_from = jcode($mail_from)->mime_encode;
    my $mail_body = $self->{body};

    my $params = {
        from => $mail_from,
        to => $mail_to,
        subject => $mail_subject,
        text => $mail_body,
    };
    my $res = $aws->ses('send-email', $params);
    if($AWS::CLIWrapper::Error->{Code}) {
        die "$AWS::CLIWrapper::Error->{Code}, $AWS::CLIWrapper::Error->{Message}";
    }
}

1;
