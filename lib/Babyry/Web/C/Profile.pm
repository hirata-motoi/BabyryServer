package Babyry::Web::C::Profile;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Profile;

sub profile_edit_name_sample_form {
    my ($class, $c) = @_;

    $c->render('/profile/edit_name_sample.tx');
}

sub profile_add_child_sample_form {
    my ($class, $c) = @_;

    $c->render('/profile/add_child_sample.tx');
}

sub profile_edit_child_sample_form {
    my ($class, $c) = @_;

    $c->render('/profile/edit_child_sample.tx');
}

sub profile_delete_child_sample_form {
    my ($class, $c) = @_;

    $c->render('/profile/delete_child_sample.tx');
}

sub get {
    my ($self, $c) = @_;

    my $logic = Babyry::Logic::Profile->new;

    my $ret = eval{ $logic->get( { user_id => $c->stash->{'user_id'} }) };
    infof($@) if($@);

    $c->render_json($ret);
}

sub edit_name {
    my ($self, $c) = @_;

    my $params = {
        user_id => $c->stash->{'user_id'},
        user_name => $c->req->param('user_name'),
    };

    my $logic = Babyry::Logic::Profile->new;
    my $ret = eval{ $logic->edit_name($params) };
    infof($@) if($@);

    $c->render_json($ret);
}

sub add_child {
    my ($self, $c) = @_;

    my $params = {
        user_id => $c->stash->{'user_id'},
        child_name => $c->req->param('child_name'),
        stamp_id => $c->req->param('stamp_id'),
    };

    my $logic = Babyry::Logic::Profile->new;
    my $ret = eval{ $logic->add_child($params) };
    infof($@) if($@);

    return $c->render_json($ret);
}

sub edit_child {
    my ($self, $c) = @_;

    my $params = {
        user_id => $c->stash->{'user_id'},
        child_id => $c->req->param('child_id'),
        child_name => $c->req->param('child_name'),
        stamp_id => $c->req->param('stamp_id'),
    };

    my $logic = Babyry::Logic::Profile->new;
    my $ret = eval{ $logic->edit_child($params) };
    infof($@) if($@);

    return $c->render_json($ret);
}

sub delete_child {
    my ($self, $c) = @_;

    my $params = {
        user_id => $c->stash->{'user_id'},
        child_id => $c->req->param('child_id'),
    };

    my $logic = Babyry::Logic::Profile->new;
    my $ret = eval{ $logic->delete_child($params) };
    infof($@) if($@);

    return $c->render_json($ret);
}

 
1;
