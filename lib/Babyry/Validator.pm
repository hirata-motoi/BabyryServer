package Babyry::Validator;

use strict;
use warnings;
use parent qw/Babyry/;
use Carp;
use Babyry::FormValidator;


sub validate {
    my ($self, $c) = @_;

    my $req = $c->req;
    my $validator = Babyry::FormValidator->new($req);
    $validator->load_constraints(qw/DATE Email URL File Number/);

    $self->do_form_validate($validator);
    $self->do_logic_validate($c, $validator);

    return $validator;
}

sub do_form_validate {
    my ($self, $validator) = @_;

    my $form_validator_conf = $self->form_validator_conf or return;
    $validator->check(%$form_validator_conf);
}

sub form_validator_conf {
    # Please implement form_validator_conf to override me.
}

sub do_logic_validate {
    # Please implement do_logic_validate to override me.
}

1;

