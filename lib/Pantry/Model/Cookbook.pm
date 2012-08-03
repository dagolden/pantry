use v5.14;
use warnings;

package Pantry::Model::Cookbook;

# ABSTRACT: Pantry data model for Chef cookbooks
# VERSION

use Moose 2;
use MooseX::Types::Path::Class::MoreCoercions qw/Dir/;
use Path::Class;
##use List::AllUtils qw/uniq first/;
##use Pantry::Model::Util qw/hash_to_dot dot_to_hash/;
use namespace::autoclean;

#--------------------------------------------------------------------------#
# Chef role attributes
#--------------------------------------------------------------------------#

has _path => (
  is        => 'ro',
  reader    => 'path',
  isa       => Dir,
  coerce    => 1,
  predicate => 'has_path',
);

has name => (
  is       => 'ro',
  isa      => 'Str',
  required => 1,
);

##has description => (
##  is => 'ro',
##  isa => 'Str',
##  lazy_build => 1,
##);
##
##sub _build_description {
##  my $self = shift;
##  return "The " . $self->name . " cookbook";
##}

=method create_boilerplate

Creates boilerplate files under the path attribute

=cut

sub create_boilerplate {
  my ($self) = @_;
  my @dirs = qw(
    attributes
    definitions
    files
    libraries
    providers
    recipes
    resources
    templates
    templates/default
  );
  my @files = qw(
    README.rdoc
    metadata.rb
    recipes/default.rb
    attributes/default.rb
  );
  for my $d ( @dirs ) {
    dir($self->path, $d)->mkpath;
  }
  for my $f ( @files ) {
    file($self->path, $f)->touch;
  }
}

1;

=head1 DESCRIPTION

Under development.

=cut

# vim: ts=2 sts=2 sw=2 et:
