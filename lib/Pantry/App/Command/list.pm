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

sub command_type {
  return 'TYPE';
}

sub options {
  my ($self) = @_;
  return ($self->selector_options);
}

sub valid_types {
  return qw/node nodes role roles/
}

sub _list_nodes {
  my ($self, $opt) = @_;
  say $_ for $self->pantry->all_nodes($opt);
}

*_list_node = *_list_nodes; # alias

sub _list_roles {
  my ($self, $opt) = @_;
  say $_ for $self->pantry->all_roles;
}

*_list_role = *_list_roles; # alias

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
