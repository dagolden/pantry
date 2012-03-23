use v5.14;
use warnings;

package Pantry::App;
# ABSTRACT: Internal pantry application class
# VERSION

use App::Cmd::Setup 0.311 -app;

sub global_opt_spec {   # none yet, so just an empty stub
  return;
}

1;

=for Pod::Coverage node_path

=cut

# vim: ts=2 sts=2 sw=2 et:
