use v5.14;
use warnings;

package Pantry::App;
# ABSTRACT: Internal pantry application superclass
# VERSION

use App::Cmd::Setup 0.317 -app;

sub global_opt_spec {   # none yet, so just an empty stub
  return;
}

1;

=head1 DESCRIPTION

This class is the internal superclass for the Pantry application, containing
any common data or methods.

=cut

# vim: ts=2 sts=2 sw=2 et:
