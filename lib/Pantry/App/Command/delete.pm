use v5.14;
use warnings;

package Pantry::App::Command::delete;
# ABSTRACT: Implements pantry delete subcommand
# VERSION

use Pantry::App -command;
use autodie;
use IO::Prompt::Tiny;
use namespace::clean;

sub abstract {
  return 'Delete an item in a pantry (nodes, roles, etc.)';
}

sub command_type {
  return 'TARGET';
}

sub options {
  return (
    ['force|f', "force deletion without confirmation"],
  );
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
    $self->usage_error( "This command requires the name for the thing to delete" );
  }

  return;
}

sub _delete_node {
  my ($self, $opt, $name) = @_;

  my $node = $self->pantry->node( $name );
  if ( ! -e $node->path ) {
    die( "Node '$name' doesn't exist\n" );
  }

  unless ( $opt->{force} ) {
    my $confirm = IO::Prompt::Tiny::prompt("Delete node '$name'?", "no");
    unless ($confirm =~ /^y(?:es)?$/i) {
      print "$name will not be deleted\n";
      exit 0;
    }
  }

  unlink $node->path;

  return;
}

1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry create node foo.example.com

=head1 DESCRIPTION

This class implements the C<pantry create> command, which is used to create a new node data file
in a pantry.

=cut

# vim: ts=2 sts=2 sw=2 et:
