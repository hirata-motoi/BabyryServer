package Babyry::Web::C::Entry;

use strict;
use warnings;
use parent qw/Babyry::Web::C Babyry::Base/;
use Log::Minimal;
use Babyry::Logic::Entry;

sub search {
    my ($self, $c) = @_;

    my $params = {
    };

    my $logic = Babyry::Logic::Entry->new;

    my $ret = eval { $logic->search($params); };
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
