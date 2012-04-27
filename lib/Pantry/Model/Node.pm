use v5.14;
use warnings;

package Pantry::Model::Node;
# ABSTRACT: Pantry data model for nodes
# VERSION

use Moose 2;
use List::AllUtils qw/uniq first/;
use namespace::autoclean;

# new_from_file, save_as
with 'Pantry::Role::Serializable' => {
  engine => 'JSON',
  engine_opts => { utf8 => 1, pretty => 1 }
};

# in_run_list, append_to_runliset
with 'Pantry::Role::Runlist';

has name => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has _path => (
  is => 'ro',
  isa => 'Str',
  predicate => 'has_path',
);

sub save {
  my ($self) = @_;
  die "No _path attribute set" unless $self->has_path;
  return $self->save_as( $self->_path );
}

1;

