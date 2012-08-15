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

sub options{
  my ($self) = @_;
  return $self->selector_options;
}

sub valid_types {
  return qw/node role environment/
}

sub _rename_node {
  my ($self, $opt, $name, $dest) = @_;
  return $self->_rename_obj($opt, 'node', $name, $dest);
}

sub _rename_role {
  my ($self, $opt, $name, $dest) = @_;
  return $self->_rename_obj($opt, 'role', $name, $dest);
}

sub _rename_environment {
  my ($self, $opt, $name, $dest) = @_;
  return $self->_rename_obj($opt, 'environment', $name, $dest);
}

sub _rename_obj {
  my ($self, $opt, $type, $name, $dest) = @_;

  my $options;
  $options->{env} = $opt->{env} if $opt->{env};
  my $obj = $self->_check_name($type, $name, $options);
  my $dest_path = $self->pantry->$type( $dest, $options )->path;

  if ( ! -e $obj->path ) {
    my $env = $opt->{env} || 'default';
    die( "$type '$name' doesn't exist in the $env environment\n" );
  }
  elsif ( -e $dest_path ) {
    die( "$type '$dest' already exists. Won't over-write it.\n" );
  }
  else {
    $obj->save_as( $dest_path );
    unlink $obj->path;
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
