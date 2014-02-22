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

sub image_comment_sample_form {
    my ($class, $c) = @_;

    $c->render('/image/comment_sample.tx');
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
    $c->render_json($ret);
}

sub comment {
    my ($self, $c) = @_;

    my $params = {
        user_id  => $c->stash->{'user_id'},
        image_id => $c->req->param('image_id'),
        comment  => $c->req->param('comment'),
    };
    return $c->render_json({error => 'NO IMAGE'}) if (!$params->{'image_id'});
    return $c->render_json({error => 'NO_COMMENT'}) if (!$params->{'comment'});

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->comment($params) } || {};
    infof($@) if($@);
    $c->render_json($ret);
}

1;

