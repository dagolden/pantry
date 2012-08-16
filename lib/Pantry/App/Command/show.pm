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
  return qw/node role environment/
}

sub _show_node {
  my ($self, $opt, $name) = @_;
  return $self->_show_obj($opt, 'node', $name);
}

sub _show_role {
  my ($self, $opt, $name) = @_;
  return $self->_show_obj($opt, 'role', $name);
}

sub _show_environment {
  my ($self, $opt, $name) = @_;
  return $self->_show_obj($opt, 'environment', $name);
}

sub _show_obj {
  my ($self, $opt, $type, $name) = @_;
  my $options;
  $options->{env} = $opt->{env} if $opt->{env};
  my $obj = $self->_check_name($type, $name, $options);
  my $path = $obj->path;
  if ( -e $path ) {
    print scalar read_file($path);
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
