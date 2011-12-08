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
    system( @editor, $path ) and die "System failed!: $!";
  }
  else {
    $self->usage_error( "EDITOR not set or not found" );
  }

  return;
}

#--------------------------------------------------------------------------#
# Internal
#--------------------------------------------------------------------------#

sub _node_guts {
  my ($self, $name) = @_;

  my $data = {
    name => $name,
    json_class => "Chef::Node",
    chef_type => "node",
    default => {},
    override => {},
    normal => {},
    automatic => {},
    run_list => [],
  };

  my $json = eval {JSON->new->pretty(1)->utf8(1)->encode($data)};
  die "JSON encoding error: $@\n" if $@;

  return $json;
}

1;

# vim: ts=2 sts=2 sw=2 et:
