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

my @types = qw/node role environment bag/;

sub valid_types {
  return map { ($_, "${_}s") } @types;
}

for my $t ( @types ) {
  no strict 'refs';
  my $plural = $t . "s";
  my $method = "all_$plural";
  *{"_list_$t"} = sub {
    my ($self, $opt) = @_;
    say $_ for $self->pantry->$method($opt);
  };
  *{"_list_$plural"} = *{"_list_$t"};
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
