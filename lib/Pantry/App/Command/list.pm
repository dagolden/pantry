use v5.14;
use warnings;

package Pantry::App::Command::list;
# ABSTRACT: Implements pantry list subcommand
# VERSION

use Pantry::App -command;
use autodie;

use namespace::clean;

sub abstract {
  return 'List pantry objects of a particular type';
}

sub usage_desc {
  my ($self) = shift;
  my ($cmd) = $self->command_names;
  return "%c $cmd <TYPE> [OPTIONS]"
}

sub description {
  my ($self) = @_;
  return $self->target_description;
}

sub target_desc {
  my ($self) = @_;
  return << 'HERE';
The TYPE parameter indicates what kind of pantry object to list.
Valid types include:

        node, nodes   lists nodes 
HERE
}

sub options {
  return;
}

sub validate {
  my ($self, $opts, $args) = @_;
  my ($type) = @$args;

  # validate type
  if ( ! length $type ) {
    $self->usage_error( "This command requires a target type" );
  }
  elsif ( $type !~ /nodes?/ ) {
    $self->usage_error( "Invalid type '$type'" );
  }

  return;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my ($type) = shift @$args;

  $self->_list_node;

  return;
}

#--------------------------------------------------------------------------#
# Internal
#--------------------------------------------------------------------------#

sub _list_node {
  my ($self) = @_;
  say $_ for $self->pantry->all_nodes;
}
1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry list nodes

=head1 DESCRIPTION

This class implements the C<pantry list> command, which is used to generate a list
of items in a pantry directory.

Supported types are:

=for :list
* C<node>, C<nodes> -- list nodes

=cut


# vim: ts=2 sts=2 sw=2 et:
