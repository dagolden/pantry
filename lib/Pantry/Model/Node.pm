use v5.14;
use warnings;

package Pantry::Model::Node;
# ABSTRACT: Pantry data model for nodes
# VERSION

use Moose 2;
use MooseX::Types::Path::Class::MoreCoercions qw/File/;
use List::AllUtils qw/uniq first/;
use Pantry::Model::Util qw/hash_to_dot dot_to_hash/;
use namespace::autoclean;

# new_from_file, save_as
with 'Pantry::Role::Serializable' => {
  freezer => '_freeze',
  thawer => '_thaw',
};

=attr name

This attribute is the canonical name of the node, generally a fully-qualified domain name

=cut

has name => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

=attr run_list

This attribute is provided by the L<Pantry::Role::Runlist> role and holds a list
of recipes (or roles) to be configured by C<chef-solo>.

=cut

# in_run_list, append_to_runlist
with 'Pantry::Role::Runlist';

has _path => (
  is => 'ro',
  reader => 'path',
  isa => File,
  coerce => 1,
  predicate => 'has_path',
);

=attr attributes

This attribute holds node attribute data as key-value pairs.  Keys may
be separated by a period to indicate nesting (literal periods must be
escaped by a backslash).  Values should be scalars or array references.

=method set_attribute

  $node->set_attribute("nginx.port", 80);

Sets the node attribute for the given key to the given value.

=method get_attribute

  my $port = $node->get_attribute("nginx.port");

Returns the node attribute for the given key.

=method delete_attribute

  $node->delete_attribute("nginx.port");

Deletes the node attribute for the given key.

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

my @top_level_keys = qw/name run_list/;

sub _freeze {
  my ($self, $data) = @_;
  my $attr = delete $data->{attributes};
  for my $k ( keys %$attr ) {
    next if grep { $k eq $_ } @top_level_keys;
    dot_to_hash($data, $k, $attr->{$k});
  }
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
  return $data;
}

1;

=head1 SYNOPSIS

  my $pantry = Pantry::Model::Pantry->new;
  my $node = $pantry->node("foo.example.com");

  $node->append_to_run_list('recipe[nginx]');
  $node->set_attribute('nginx.port' => 80);
  $node->save;

=head1 DESCRIPTION

Models the configuration data for a specific server.

=cut


