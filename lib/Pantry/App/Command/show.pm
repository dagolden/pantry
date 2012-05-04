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
  return qw/node/
}

sub _show_node {
  my ($self, $opt, $name) = @_;
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
