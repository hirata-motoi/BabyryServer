package Babyry::Web::C::Wall;

use strict;
use warnings;
use parent qw/Babyry::Web::C/;

use Log::Minimal;

use Babyry::Logic::Wall;
use Babyry::Logic::Session;

sub index {
    my ($class, $c, $p, $v) = @_;

    my $user_id = $c->stash->{'user_id'};

    my $wall = Babyry::Logic::Wall->new->show($user_id);
    return $c->render('index.tx', {
        user_id  => $user_id,
        wall     => $wall,
    });
}

sub detail {
    my ($class, $c) = @_;
    return $c->render('detail/index.tx', +{
    });
}

sub json_validate_sample {
    my ($class, $c, $p, $validator) = @_;

    if ( $validator->has_error ) {
        $validator->set_error_message('test');
        return $c->render_json_validation_error($validator);
    }

    return $c->render_json( +{} );
}


1;

