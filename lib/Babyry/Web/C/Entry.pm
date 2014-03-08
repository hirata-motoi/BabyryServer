package Babyry::Web::C::Entry;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;
use Log::Minimal;
use Babyry::Logic::Entry;

sub search {
    my ($self, $c) = @_;

    my $stamp_id    = $c->req->param('stamp_id')    || 0;
    my $uploaded_by = $c->req->param('uploaded_by') || $c->stash->{user_id};
    my $count       = $c->req->param('count')       || 10;
    my $page        = $c->req->param('page')        || 1;

    my $params = {
        stamp_id    => $stamp_id,
        uploaded_by => $uploaded_by,
        count       => $count,
        page        => $page,
    };

    my $logic = Babyry::Logic::Entry->new;

    my $ret = {};

    my $data = $logic->search($params);
    my $found_row_count = delete $data->{found_row_count};
    $ret->{data} = $data;

    $ret->{metadata} = {
        count           => $count,
        page            => $page,
        found_row_count => $found_row_count,
        condition => {
            stamp_id    => $stamp_id,
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
