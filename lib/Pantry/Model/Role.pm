use v5.14;
use warnings;

package Pantry::Model::Role;
# ABSTRACT: Pantry data model for Chef roles
# VERSION

use Moose 2;
use MooseX::Types::Path::Class::MoreCoercions qw/File/;
use List::AllUtils qw/uniq first/;
use namespace::autoclean;

# new_from_file, save_as
with 'Pantry::Role::Serializable';

# in_run_list, append_to_runliset
with 'Pantry::Role::Runlist';

#--------------------------------------------------------------------------#
# static keys/values required by Chef
#--------------------------------------------------------------------------#

has chef_type => (
  is => 'bare',
  isa => 'Str',
  default => 'role',
  init_arg => undef,
);

has json_class => (
  is => 'bare',
  isa => 'Str',
  default => 'Chef::Role',
  init_arg => undef,
);

#--------------------------------------------------------------------------#
# Chef role attributes
#--------------------------------------------------------------------------#

has _path => (
  is => 'ro',
  reader => 'path',
  isa => File,
  coerce => 1,
  predicate => 'has_path',
);

has name => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has description => (
  is => 'ro',
  isa => 'Str',
  lazy_build => 1,
);

sub _build_description {
  my $self = shift;
  return "The " . $self->name . " role";
}

=method save

Saves the node to a file in the pantry.  If the private C<_path>
attribute has not been set, an exception is thrown.

=cut

sub save {
  my ($self) = @_;
  die "No _path attribute set" unless $self->has_path;
  return $self->save_as( $self->path );
}

1;

=head1 DESCRIPTION

Under development.

=cut

# vim: ts=2 sts=2 sw=2 et:
