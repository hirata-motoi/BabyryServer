package Babyry::Web::C::Entry;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Entry;
use Data::Dumper;

sub search {
    my ($self, $c) = @_;

    my @child_id    = $c->req->param('child_id');
    my $uploaded_by = $c->req->param('uploaded_by') || $c->stash->{user_id};
    my $count       = $c->req->param('count')       || 10;
    my $page        = $c->req->param('page')        || 1;
    my $offset      = $c->req->param('offset');
    my $user_id     = $c->stash->{user_id};

    my $params = {
        child_id    => \@child_id,
        uploaded_by => $uploaded_by,
        count       => $count,
        page        => $page,
        offset      => $offset,
        user_id     => $user_id,
    };

    my $logic = Babyry::Logic::Entry->new;

    my $ret = {};

    my $data = $logic->search($params);
    my $found_row_count = delete $data->{found_row_count};
    $ret->{data} = $data;

    $ret->{metadata} = {
        count           => $count,
        offset          => $offset,
        page            => $page,
        found_row_count => $found_row_count,
        condition => {
            uploaded_by => $uploaded_by
        },
    };
    if ( my $e = $@ ) {
critf($e);
#        critf('Failed to register params:%s error:%s', $self->dump($params), $e);
#        $c->render_500();
    }
    if ( $ret->{error} ) {
critf($ret->{error});
#        critf('Failed to register params:%s error:%s', $self->dump($params), $self->dump( $ret->{error} ));
#        $c->render_500();
    }

    $c->render_json($ret);
}
 
1;
