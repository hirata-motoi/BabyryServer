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

    my $data = Babyry::Logic::Image->new->web_upload($c->stash->{user_id});
    $c->render('/image/upload.tx', $data);
}

sub web_upload_execute {
    my ($self, $c) = @_;

    return $c->render_500() if ! $c->stash->{user_id};

    my $file = $c->req->uploads->get_all('file');

    my $params = {
        user_id => $c->stash->{user_id},
        path    => $file->path,
    };

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->web_upload_execute($params) } || {};
    infof($@) if($@);
    $self->output_response_json($c, $ret, $@);
}

sub web_submit {
    my ($self, $c) = @_;

    my @image_list = $c->req->param('image_tmp_names[]');
    my @user_list  = $c->req->param('shared_user_ids[]');
    my @child_list  = $c->req->param('target_child_ids[]');
    my $child_id = $c->req->param('child_id') || "";
    my $is_icon = $c->req->param('is_icon') || "";

    # わかりづらいが、child_idが入っている場合は、アイコンとして画像が上げられた場合
    # target_child(配列)は画像にこどもがひもづけられている状態
    my $params = {
        user_id => $c->stash->{'user_id'},
        user    => \@user_list,
        image   => \@image_list,
        child   => \@child_list,
        child_id => $child_id,
        is_icon => $is_icon,
    };

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->web_submit($params) } || {};
    $self->output_response_json($c, $ret, $@);
}

sub web_remove {
    my ($self, $c) = @_;

    my $params = {
        image_id => $c->req->param('image_id')
    };

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->web_remove($params) } || {};
    $self->output_response_json($c, $ret, $@);
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
    $self->output_response_json($c, $ret, $@);
}

sub child_attach {
    my ($self, $c) = @_;

    my $params = {
        user_id  => $c->stash->{user_id},
        image_id => $c->req->param('image_id'),
        child_id => $c->req->param('child_id'),
    };

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->child_attach($params) } || {};
    $self->output_response_json($c, $ret, $@);
}

sub child_detach {
    my ($self, $c) = @_;

    my $params = {
        user_id  => $c->stash->{user_id},
        image_id => $c->req->param('image_id'),
        child_id => $c->req->param('child_id'),
    };

    my $logic = Babyry::Logic::Image->new;
    my $ret = eval { $logic->child_detach($params) } || {};
    $self->output_response_json($c, $ret, $@);
}

1;

