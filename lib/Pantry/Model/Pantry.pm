use v5.14;
use warnings;

package Pantry::Model::Pantry;
# ABSTRACT: Pantry data model for a pantry directory
# VERSION

use Moose 2;
use MooseX::Types::Path::Class::MoreCoercions 0.002 qw/AbsDir/;
use namespace::autoclean;

use Path::Class;

has path => (
  is => 'ro',
  isa => AbsDir,
  coerce => 1,
  default => sub { dir(".")->absolute }
);

sub _node_path {
  my ($self, $node_name, $env) = @_;
  $env //= '_default';
  return $self->path->file("environments/${env}/${node_name}.json");
}

sub node {
  my ($self, $node_name, $env) = @_;
  require Pantry::Model::Node;
  my $path = $self->_node_path( $node_name );
  if ( -e $path ) {
    return Pantry::Model::Node->new_from_file( $path );
  }
  else {
    return Pantry::Model::Node->new( name => $node_name, _path => $path );
  }
}

1;

