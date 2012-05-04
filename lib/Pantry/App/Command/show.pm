use v5.14;
use warnings;

package Pantry::App::Command::show;
# ABSTRACT: Implements pantry show subcommand
# VERSION

use Pantry::App -command;
use autodie;
use File::Slurp qw/read_file/;

use namespace::clean;

sub abstract {
  return 'Show items in a pantry (nodes, roles, etc.)';
}

sub help_type {
  return 'TARGET';
}

sub validate {
  my ($self, $opts, $args) = @_;
  my ($type, $name) = @$args;

  # validate type
  if ( ! length $type ) {
    $self->usage_error( "This command requires a target type and name" );
  }
  elsif ( $type ne 'node' ) {
    $self->usage_error( "Invalid type '$type'" );
  }

  # validate name
  if ( ! length $name ) {
    $self->usage_error( "This command requires the name for the thing to display" );
  }

  return;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my ($type, $name) = splice(@$args, 0, 2);

  if ($type eq 'node') {
    $self->_show_node($name);
  }

  return;
}

#--------------------------------------------------------------------------#
# Internal
#--------------------------------------------------------------------------#

sub _show_node {
  my ($self, $name) = @_;
  my $path = $self->pantry->node($name)->path;
  if ( -e $path ) {
    print scalar read_file($path);
  }
  else {
    $self->usage_error( "Node '$name' does not exist" );
  }
  return;
}

1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry show node foo.example.com

=head1 DESCRIPTION

This class implements the C<pantry show> command, which is used to
display the JSON data for a node.

=cut

# vim: ts=2 sts=2 sw=2 et:
