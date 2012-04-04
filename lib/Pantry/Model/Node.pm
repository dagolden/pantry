use v5.14;
use warnings;

package Pantry::Model::Node;
# ABSTRACT: Pantry data model for nodes
# VERSION

use Moose 2;
use List::AllUtils qw/uniq first/;

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
  is => 'bare',
  isa => 'ArrayRef[Str]',
  traits => ['Array'],
  default => sub { [] },
  handles => {
    run_list => 'elements',
    _push_run_list => 'push',
  },
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
# methods
#--------------------------------------------------------------------------#

sub in_run_list {
  my ($self, $item) = @_;
  return first { $item eq $_ } $self->run_list;
}

sub append_to_runlist {
  my ($self, @items) = @_;
  for my $i (@items) {
    $self->_push_run_list($i)
      unless $self->in_run_list($i);
  }
  return;
}

#--------------------------------------------------------------------------#
# private methods
#--------------------------------------------------------------------------#


1;

