use v5.14;
use warnings;

package Pantry::App::Command::clidump;
# ABSTRACT: dump options as JSON
# VERSION

use Pantry::App -command;
use autodie;
use JSON;

use namespace::clean;

sub abstract {
  return 'dump command line options and remaining args';
}

sub options {
  my ($self) = @_;
  return $self->data_options;
}

sub validate {
  return;
}

sub execute {
  my ($self, $opt, $args) = @_;
  $opt  //= {};
  $args //= [];

  say JSON->new->utf8->pretty->canonical->encode({
      args => $args,
      opts => { %$opt }, # XXX
    }
  );
  return;
}

1;

=for Pod::Coverage options validate

=cut

# vim: ts=2 sts=2 sw=2 et:
