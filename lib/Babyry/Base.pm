package Babyry::Base;
use strict;
use warnings;
use utf8;
use parent qw/Babyry/;

use Babyry::DBI;
use DBIx::Simple;
use Teng::Schema::Loader;
use SQL::Abstract;
use Data::Dump;

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

    return $self->{teng} if $self->{teng};

    my $teng = Teng::Schema::Loader->load(
        namespace => 'Babyry::Teng',
        dbh       => $self->dbh($label),
    );
    $teng->load_plugin('Count');
    $self->{teng} = $teng;
    return $self->{teng};
}

sub sql {
    my ($self) = @_;
    return SQL::Abstract->new;
}

sub dump {
    my ($self, $params) = @_;
    return Data::Dump::dump($params);
}


1;
