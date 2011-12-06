use v5.14;
use warnings;

package Pantry::App::Command::init;
# ABSTRACT: Implements pantry init subcommand
# VERSION

use Pantry::App -command;

sub abstract {
  return 'initialize a pantry in the current directory';
}

sub options {
  return;
}

sub validate {
  return;
}

sub execute {
  my ($self, $opt, $args) = @_;

}

1;

# vim: ts=2 sts=2 sw=2 et:
