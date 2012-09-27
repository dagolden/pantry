use v5.14;
use warnings;

package Pantry::Model::DataBag;
# ABSTRACT: Pantry data model for Chef data bags
# VERSION

use Moose 2;
use MooseX::Types::Path::Class::MoreCoercions qw/File/;
use Carp qw/croak/;
use List::AllUtils qw/uniq first/;
use Pantry::Model::EnvRunList;
use Pantry::Model::Util qw/hash_to_dot dot_to_hash/;
use namespace::autoclean;

# new_from_file, save_as
with 'Pantry::Role::Serializable' => {
  freezer => '_freeze',
  thawer => '_thaw',
};

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
  return "The " . $self->name . " data bag";
}

=attr attributes

This attribute holds data bag attribute data as key-value pairs.  Keys may
be separated by a period to indicate nesting (literal periods must be
escaped by a backslash).  Values should be scalars or array references.

=method set_attribute

  $role->set_attribute("shell", "/bin/bash");

Sets the role default attribute for the given key to the given value.

=method get_attribute

  my $port = $role->get_attribute("shell");

Returns the bag attribute for the given key.

=method delete_attribute

  $role->delete_attribute("shell");

Deletes the bag attribute for the given key.

=cut

has attributes => (
  is => 'bare',
  isa => 'HashRef',
  traits => ['Hash'],
  default => sub { +{} },
  handles => {
    set_attribute => 'set',
    get_attribute => 'get',
    delete_attribute => 'delete',
  },
);


=method save

Saves the node to a file in the pantry.  If the private C<_path>
attribute has not been set, an exception is thrown.

=cut

sub save {
  my ($self) = @_;
  die "No _path attribute set" unless $self->has_path;
  return $self->save_as( $self->path );
}

my @top_level_keys = qw/id/;

sub _freeze {
  my ($self, $data) = @_;
  my $id = delete $data->{name};
  my $attr = delete $data->{attributes};
  for my $k ( keys %$attr ) {
    next if grep { $k eq $_ } @top_level_keys;
    dot_to_hash($data, $k, $attr->{$k});
  }
  $data->{id} = $id;
  return $data;
}

sub _thaw {
  my ($self, $data) = @_;
  my $attr = {};
  for my $k ( keys %$data ) {
    next if grep { $k eq $_ } @top_level_keys;
    my $v = delete $data->{$k};
    $k =~ s{\.}{\\.}g; # escape existing dots in key
    for my $pair ( hash_to_dot($k, $v) ) {
      my ($key, $value) = @$pair;
      $attr->{$key} = $value;
    }
  }
  $data->{attributes} = $attr;
  $data->{name} = delete $data->{id};
  return $data;
}


1;

=head1 DESCRIPTION

Under development.

=cut

# vim: ts=2 sts=2 sw=2 et:
