package Babyry::Web::C::Image;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Data::Dumper;
use Imager;

use Babyry::Logic::Image;
use Babyry::Logic::Session;

my $image = Babyry::Logic::Image->new();

sub image_upload_sample_form {
    my ($class, $c) = @_;

    $c->render('/image/upload_sample.tx');
}

sub image_submit_sample_form {
    my ($class, $c) = @_;

    $c->render('/image/submit_sample.tx');
}

sub web_upload {
    my ($self, $c) = @_;

    return $c->render_500() if ! $c->stash->{user_id};

    my $file = $c->req->uploads->get_all('file');

    my $params = {
        user_id => $c->stash->{user_id},
        path    => $file->path,
    };

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->web_upload($params) } || {};
    infof($@) if($@);
    $c->render_json($ret);
}

sub web_submit {
    my ($self, $c) = @_;

    my $user_list = $c->req->env->{'plack.request.http.body'}->param->{'user[]'};
    my $image_list = $c->req->env->{'plack.request.http.body'}->param->{'image[]'};

    my $params = {
        user_id => $c->stash->{'user_id'},
        user    => $user_list,
        image   => $image_list,
    };

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->web_submit($params) } || {};
    infof($@) if($@);
    $c->render_json($ret);
}

1;

