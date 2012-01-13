use v5.14;
use warnings;

package Pantry::App::Command::init;
# ABSTRACT: Implements pantry init subcommand
# VERSION

use Pantry::App -command;
use autodie;

sub abstract {
  return 'initialize a pantry in the current directory';
}

sub options {
  return;
}

sub validate {
  return;
}

my @pantry_dirs = qw(
  cookbooks
  roles
  environments
);

sub execute {
  my ($self, $opt, $args) = @_;

  for my $d ( @pantry_dirs ) {
    if ( -d $d ) {
      say "Directory '$d' already exists";
    }
    else {
      mkdir $d;
      say "Directory '$d' created";
    }
  }
  return;
}

1;

=for Pod::Coverage options validate

=cut

# vim: ts=2 sts=2 sw=2 et:
