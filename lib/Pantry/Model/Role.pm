use v5.14;
use warnings;

package Pantry::Model::Role;
# ABSTRACT: Pantry data model for roles
# VERSION

use Moose 2;
use List::AllUtils qw/uniq first/;
use namespace::autoclean;

# new_from_file, save_as
with 'Pantry::Role::Serializable' => {
  engine => 'JSON',
  engine_opts => { utf8 => 1, pretty => 1 }
};

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

has name => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has description => (
  is => 'ro',
  isa => 'Str',
  lazy_builder => 1,
);

sub _build_description {
  my $self = shift;
  return "The " . $self->name . " role";
}

1;

