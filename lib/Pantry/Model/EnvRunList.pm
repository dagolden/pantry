use v5.14;
use strict;
use warnings;

package Pantry::Model::EnvRunList;
# ABSTRACT: Standalone runlist object for environment runlists
# VERSION

use Moose 2;
use namespace::autoclean;

with 'Pantry::Role::Runlist';

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Pantry::Model::EnvRunList;

=head1 DESCRIPTION

Chef Roles can have environment-specific runlists.  This is a standalone
runlist object that merely instantiates the the Pantry::Role::Runlist role.

=cut

# vim: ts=2 sts=2 sw=2 et:
