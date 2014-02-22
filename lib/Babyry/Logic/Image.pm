package Babyry::Logic::Image;

use strict;
use warnings;

use utf8;
use Log::Minimal;

use parent qw/Babyry::Logic::Base/;

use Babyry::Logic::Sequence;
use Babyry::Service::Image;

sub set_image_info {
    my ($self, $file) = @_;

    my $sequence = Babyry::Logic::Sequence->new();
    my $image_id = $sequence->get_id('seq_image');

    return 0 if ($file !~ /^(\d+)_(\d+)\.(jpg|jped|png)$/);
    my $user_id = $1;
    my $t = $2,

    my $dbh = $self->dbh('TEST_W');
    my $sth = $dbh->prepare("insert into image (image_id, channel_id, uploaded_by, disabled, updated_at, created_at) values (?,?,?,?,?,?)");
    $sth->execute($image_id, 1, $user_id, 0, $t, $t);
    $dbh->commit;
    return 1;
}

sub get_image_url_image_id {
    my ($self, $image_id) = @_;

    my $bucket = 'bebyry-image-upload';

    my $dbh = $self->dbh('TEST_R');
    my $sth = $dbh->prepare("select uploaded_by, created_at from image where image_id = ?");
    $sth->execute($image_id);
    my $row = $sth->fetchrow_hashref();
    my $user_id = $row->{uploaded_by};
    my $t = $row->{created_at};
    my $key = $user_id . '_' . $t . '.jpg';

    my $home_dir = Babyry->base_dir;
    my $ruby = "/home/babyry/.rbenv/shims/ruby $home_dir/lib/Babyry/Logic/get_onetime_url.rb";
    my $url = `$ruby $bucket $key`;
    chomp($url);

    return $url;
}

sub web_upload {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->web_upload($params);
}

sub web_submit {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->web_submit($params);
}

sub comment {
    my ($self, $params) = @_;

    my $service = Babyry::Service::Image->new;
    return $service->comment($params);
}


1;

