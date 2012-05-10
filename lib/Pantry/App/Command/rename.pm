use v5.14;
use warnings;

package Pantry::App::Command::rename;
# ABSTRACT: Implements pantry rename subcommand
# VERSION

use Pantry::App -command;
use autodie;

use namespace::clean;

sub abstract {
  return 'Rename an item in a pantry (nodes, roles, etc.)';
}

sub command_type {
  return 'DUAL_TARGET';
}

sub valid_types {
  return qw/node role/
}

sub _rename_node {
  my ($self, $opt, $name, $dest) = @_;

  my $node = $self->pantry->node( $name );
  my $dest_path = $self->pantry->node( $dest )->path;
  if ( ! -e $node->path ) {
    die( "Node '$name' doesn't exist\n" );
  }
  elsif ( -e $dest_path ) {
    die( "Node '$dest' already exists. Won't over-write it.\n" );
  }
  else {
    $node->save_as( $dest_path );
    unlink $node->path;
  }

  return;
}

sub _rename_role {
  my ($self, $opt, $name, $dest) = @_;

  my $role = $self->pantry->role( $name );
  my $dest_path = $self->pantry->role( $dest )->path;
  if ( ! -e $role->path ) {
    die( "role '$name' doesn't exist\n" );
  }
  elsif ( -e $dest_path ) {
    die( "role '$dest' already exists. Won't over-write it.\n" );
  }
  else {
    $role->save_as( $dest_path );
    unlink $role->path;
  }

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
