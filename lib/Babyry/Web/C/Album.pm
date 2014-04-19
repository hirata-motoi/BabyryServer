package Babyry::Web::C::Album;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Album;

sub search {
    my ($self, $c) = @_;

    my $logic = Babyry::Logic::Album->new;

    my $ret = eval { $logic->search({user_id => $c->stash->{user_id}}); };
    if ( my $e = $@ ) {
        critf($e);
    }
    if ( $ret->{error} ) {
        critf($ret->{error});
    }

    $c->render_json($ret);
}

sub add_attr {
    my ($self, $c) = @_;
    my $logic = Babyry::Logic::Album->new;
    my $params = {
        album_id => $c->req->param('album_id'),
        key => $c->req->param('key'),
        attr => $c->req->param('attr'),
    };
    my $ret = eval { $logic->add_attr($params); };
    if ( my $e = $@ ) {
        critf($e);
        $ret = {error => $e};
    }
    $c->render_json($ret);
}

sub edit_name {
    my ($self, $c) = @_;
    my $logic = Babyry::Logic::Album->new;
    my $params = {
        album_id => $c->req->param('album_id'),
        album_name => $c->req->param('album_name'),
    };
    my $ret = eval { $logic->edit_name($params); };
    if ( my $e = $@ ) {
        critf($e);
        $ret = {error => $e};
    }
    $c->render_json($ret);
}

sub delete_attr {
    my ($self, $c) = @_;
    my $logic = Babyry::Logic::Album->new;
    my $params = {
        album_id => $c->req->param('album_id'),
        attr_key => $c->req->param('attr_key'),
        attr_value => $c->req->param('attr_value'),
    };
    my $ret = eval { $logic->delete_attr($params); };
    if ( my $e = $@ ) {
        critf($e);
        $ret = {error => $e};
    }
    $c->render_json($ret);
}
 
1;
