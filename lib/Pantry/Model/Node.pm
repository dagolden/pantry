use v5.14;
use warnings;

package Pantry::Model::Node;
# ABSTRACT: Pantry data model for nodes
# VERSION

use Moose 2;
use MooseX::Types::Path::Class::MoreCoercions qw/File/;
use List::AllUtils qw/uniq first/;
use namespace::autoclean;

# new_from_file, save_as
with 'Pantry::Role::Serializable' => {
  engine => 'JSON',
  engine_opts => { utf8 => 1, pretty => 1 },
  freezer => '_freeze',
  thawer => '_thaw',
};

# in_run_list, append_to_runliset
with 'Pantry::Role::Runlist';

has name => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has _path => (
  is => 'ro',
  isa => File,
  coerce => 1,
  predicate => 'has_path',
);

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

sub save {
  my ($self) = @_;
  die "No _path attribute set" unless $self->has_path;
  return $self->save_as( $self->_path );
}

my @top_level_keys = qw/name run_list/;

sub _freeze {
  my ($self, $data) = @_;
  my $attr = delete $data->{attributes};
  for my $k ( keys %$attr ) {
    next if grep { $k eq $_ } @top_level_keys;
    $self->_dot_to_hash($data, $k, $attr->{$k});
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
    for my $pair ( $self->_hash_to_dot($k, $v) ) {
      my ($key, $value) = @$pair;
      $attr->{$key} = $value;
    }
  }
  $data->{attributes} = $attr;
  return $data;
}

sub _dot_to_hash {
  my ($self, $hash, $key, $value) = @_;

  my ($top_key, $rest) = split qr{(?<!\\)\.}, $key, 2;
  if ( $rest ) {
    my $new_hash = $hash->{$top_key} || {};
    $self->_dot_to_hash($new_hash, $rest, $value);
    $hash->{$top_key} = $new_hash;
  }
  else {
    # un-escape '\.'
    $key =~ s{\\\.}{.}g;
    $hash->{$key} = $value;
    return;
  }
}

sub _hash_to_dot {
  my ($self, $key, $value) = @_;
  if ( ref $value eq 'HASH' ) {
    my @pairs;
    for my $k ( keys %$value ) {
      my $v = $value->{$k};
      $k =~ s{\.}{\\.}g; # escape existing dots in key
      for my $item ( $self->_hash_to_dot($k, $v) ) {
        $item->[0] = "$key\.$item->[0]";
        push @pairs, $item;
      }
    }
    return @pairs;
  }
  else {
    return [$key, $value];
  }
}

1;

