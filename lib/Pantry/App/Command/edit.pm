use v5.14;
use warnings;

package Pantry::App::Command::edit;
# ABSTRACT: Implements pantry edit subcommand
# VERSION

use Pantry::App -command;
use autodie;
use File::Basename qw/dirname basename/;
use File::Slurp qw/read_file/;
use IPC::Cmd qw/can_run/;
use JSON qw/decode_json/;

use namespace::clean;

sub abstract {
  return 'Edit items in a pantry (nodes, roles, etc.)';
}

sub command_type {
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
    $self->usage_error( "This command requires the name for the thing to edit" );
  }

  return;
}

sub _edit_node {
  my ($self, $opt, $name) = @_;

  my @editor = defined $ENV{EDITOR} ? split / /, $ENV{EDITOR} : ();
  if ( @editor ) {
    $editor[0] = can_run($editor[0]);
  }

  if ( @editor ) {
    $self->_edit_file($name, @editor);
  }
  else {
    $self->usage_error( "EDITOR not set or not found" );
  }

  return;
}

#--------------------------------------------------------------------------#
# Internal
#--------------------------------------------------------------------------#

sub _edit_file {
  my ($self, $name, @editor) = @_;
  my $path = $self->pantry->node($name)->path;
  if ( -e $path ) {
    system( @editor, $path ) and die "System failed!: $!";
    eval { decode_json(read_file($path,{ binmode => ":raw" })) };
    if ( my $err = $@ ) {
      $err =~ s/, at .* line .*//;
      warn "Warning: JSON errors in config for $name\n";
    }
  }
  else {
    $self->usage_error("Node '$name' does not exist");
  }
}

1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry edit node foo.example.com

=head1 DESCRIPTION

This class implements the C<pantry edit> command, which is used to open the node data
JSON file in an editor for direct editing.

=cut

# vim: ts=2 sts=2 sw=2 et:
