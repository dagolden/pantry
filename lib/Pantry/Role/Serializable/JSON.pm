use 5.010;
use strict;
use warnings;
package Pantry::Role::Serializable::JSON;
# ABSTRACT: JSON engine for Pantry::Role::Serializable
# VERSION

use Moose 2;
use namespace::autoclean;

use JSON 2;

has engine_opts => (
  is => 'ro',
  isa => 'HashRef',
  default => sub { {} },
);

sub freeze {
  my ($self, $data) = @_;
  my $string = to_json($data, $self->engine_opts);
  return \$string;
}

sub thaw {
  my ($self, $str_ref) = @_;
  my $data = from_json($$str_ref, $self->engine_opts);
  return $data;
}

__PACKAGE__->meta->make_immutable;

1;

