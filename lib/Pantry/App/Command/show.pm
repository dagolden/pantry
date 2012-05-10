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

sub command_type {
  return 'TARGET';
}

sub valid_types {
  return qw/node role/
}

sub _show_node {
  my ($self, $opt, $name) = @_;
  return $self->_show_obj($opt, 'node', $name);
}

sub _show_role {
  my ($self, $opt, $name) = @_;
  return $self->_show_obj($opt, 'role', $name);
}

sub _show_obj {
  my ($self, $opt, $type, $name) = @_;
  my $path = $self->pantry->$type($name)->path;
  if ( -e $path ) {
    print scalar read_file($path);
  }
  else {
    $self->usage_error( "$type '$name' does not exist" );
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
