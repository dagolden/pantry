use v5.14;
use warnings;

package Pantry::App::Command::edit;
# ABSTRACT: Implements pantry edit subcommand
# VERSION

use Pantry::App -command;
use autodie;
use File::Basename qw/dirname/;
use File::Path qw/mkpath/;
use File::Slurp qw/write_file/;
use IPC::Cmd qw/can_run/;
use JSON;

use namespace::clean;

sub abstract {
  return 'edit items in a pantry (nodes, roles, etc.)';
}

sub options {
  return;
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
  elsif ( ! -e $self->app->node_path($name) ) {
    $self->usage_error( "Node '$name' does not exist" );
  }

  return;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my ($type, $name) = splice(@$args, 0, 2);
  my $path = $self->app->node_path($name);

  my @editor = defined $ENV{EDITOR} ? split / /, $ENV{EDITOR} : ();
  if ( @editor ) {
    $editor[0] = can_run($editor[0]);
  }

  if ( @editor ) {
    _edit_file(\@editor, $path);
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
  my ($editor, $path) = @_;
  system( @$editor, $path ) and die "System failed!: $!";
}

1;

=for Pod::Coverage options validate

=cut

# vim: ts=2 sts=2 sw=2 et:
