use v5.14;
use warnings;

package Pantry::App::Command::list;
# ABSTRACT: Implements pantry list subcommand
# VERSION

use Pantry::App -command;
use autodie;
use Path::Class::Rule;

use namespace::clean;

sub abstract {
  return 'list information about pantry contents';
}

sub options {
  return;
}

sub validate {
  my ($self, $opts, $args) = @_;
  my ($type) = @$args;

  # validate type
  if ( ! length $type ) {
    $self->usage_error( "This command requires a target type and name" );
  }
  elsif ( $type !~ /nodes?/ ) {
    $self->usage_error( "Invalid type '$type'" );
  }

  return;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my ($type) = shift @$args;

  $self->_list_node;

  return;
}

#--------------------------------------------------------------------------#
# Internal
#--------------------------------------------------------------------------#

sub _list_node {
  my ($self) = @_;
  my $pcr = Path::Class::Rule->new->file->name("*.json");
  say $_->basename for $pcr->all("environments/_default");
}
1;

=for Pod::Coverage options validate

=cut

# vim: ts=2 sts=2 sw=2 et:
