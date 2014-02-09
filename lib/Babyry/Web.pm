package Babyry::Web;
use strict;
use warnings;
use utf8;
use parent qw/Babyry Amon2::Web/;
use File::Spec;
use Log::Minimal;
use Carp;
use Babyry::Web::Root;

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::JSON',
    '+Babyry::Web::Plugin::Session',
    'Web::Stash' => +{
       autorender => 1,
    },
);

# dispatcher
use Babyry::Web::Dispatcher;
sub dispatch {
    return ( Babyry::Web::Dispatcher->dispatch($_[0]) or __exception("response is not generated") );
}

sub __exception {
    my $msg = shift;
    critff($msg);
    croak($msg);
}


# setup view
use Babyry::Web::View;
{
    sub create_view {
        my $view = Babyry::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *Babyry::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

sub render_json_validation_error {
    my ($c, $validator) = @_;

    my $messages = $validator->get_messages();
    $c->render_json( +{ error_messages => $messages } );
}


# for your security
__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ($c, $res) = @_;
        my $session_id = $c->session->get('session_id');

        # TODO move to config
        my @session_not_required_paths = qw| /login /login/execute /register /register/execute /register/verify |;

        my $path = $c->req->env->{PATH_INFO};
        if ( ! $session_id  ) {
            if ( ! grep { $path =~ m{^$_} } @session_not_required_paths ) {
                infof('redirect to /login');
                return $c->redirect('/login');
            }
            return;
        } else {
            if ( grep { $_ eq $path } @session_not_required_paths ) {
                infof('redirect to /');
                return $c->redirect('/');
            }
        }


        my $base_info = Babyry::Web::Root->new->certify($session_id);
        for my $key (keys %$base_info) {
            $c->stash->{$key} = $base_info->{$key};
        }

        # when session is invalid
        if ( ! $c->stash->{user_id} ) {
            return $c->redirect('/login');
        }
    },

    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

1;
