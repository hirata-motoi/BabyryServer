package Babyry::Model::UploadS3;

use strict;
use warnings;

use AWS::CLIWrapper;
use Log::Minimal;
use parent qw/Babyry::Model::Base/;

use Babyry::Common;

sub tmp_upload {
    my ($self, $dir, $images, $format) = @_;
    
    my $bucket = Babyry::Common->config->{tmp_bucket};

    my $aws = AWS::CLIWrapper->new();
    
    for my $img (@{$images}) {
        my $full_path = "$dir/$img";
        my $params = +{
            body => $full_path,
            key => $img,
            bucket => $bucket,
            'content-type' => "image/${format}",
        };
        for (1 .. 2) {
            my $res = $aws->s3api('put-object', $params);
            if (!$res) {
                die "failed to put-object : $AWS::CLIWrapper::Error->{Code} : $AWS::CLIWrapper::Error->{Message}";
            } else {
                my $params2 = +{
                    prefix => $img,
                    bucket => $bucket,
                };
                my $res2 = $aws->s3api('list-objects', $params2);
                if($res2) {
                    my $s3_size = $res2->{Contents}[0]->{Size};
                    if(-s $full_path == $s3_size) {
                        unlink($full_path);
                        last;
                    } else {
                        die "failed to remove $full_path";
                    }
                } else {
                    die "failed to list object : $AWS::CLIWrapper::Error->{Code} : $AWS::CLIWrapper::Error->{Message}";
                }
            }
        }
    }

    return;
}

1;
