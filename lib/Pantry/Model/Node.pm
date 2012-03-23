use v5.14;
use warnings;

package Pantry::Model::Node;
# ABSTRACT: Pantry data model for nodes
# VERSION

use Moose 2;

# new_from_file, save_as
with 'Pantry::Role::Serializable' => {
  engine => 'JSON',
  engine_opts => { utf8 => 1, pretty => 1 }
};

use namespace::autoclean;

has name => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has run_list => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub { [] },
);

#--------------------------------------------------------------------------#
# class methods
#--------------------------------------------------------------------------#

sub node_path {
  my ($class, $name, $pantry, $env) = @_;
  $env //= '_default';
  return "${pantry}/environments/${env}/${name}.json";
}

#--------------------------------------------------------------------------#
# private methods
#--------------------------------------------------------------------------#


1;

