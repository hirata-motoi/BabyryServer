package Babyry::Service::Base;
use strict;
use warnings;
use utf8;

use parent qw/Class::Accessor::Fast/;

use Babyry::DBI;
use DBIx::Simple;
use Teng::Schema::Loader;
use SQL::Abstract;
use Data::Dump;
use Class::Load qw/load_class/;
use String::CamelCase qw/camelize/;

sub dbh {
    my ($self, $label) = @_;

    my $resolver = Babyry::DBI->resolver();
    my $dbh = $resolver->connect($label);
    $dbh;
}

sub dx {
    my ($self, $label, $dbh) = @_;

    $dbh ||= $self->dbh($label);
    my $dx = DBIx::Simple->new($dbh);
    return $dx;
}

sub teng {
    my ($self, $label) = @_;

    $self->{teng} ||= {};
    return $self->{teng}{$label} if $self->{teng}{$label};

    my $teng = Teng::Schema::Loader->load(
        namespace => 'Babyry::Teng',
        dbh       => $self->dbh($label),
    );
    $teng->load_plugin('Count');
    $self->{teng}{$label} = $teng;
    return $self->{teng}{$label};
}

sub sql {
    my ($self) = @_;
    return SQL::Abstract->new;
}

sub dump {
    my ($self, $params) = @_;
    return Data::Dump::dump($params);
}

sub model {
    my ($self, $model_name) = @_;

    my $class = 'Babyry::Model::' . camelize($model_name);
    load_class($class);
    return $class->new;
}

1;

