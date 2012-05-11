use v5.14;
use warnings;

package Pantry::App::Command::strip;
# ABSTRACT: Implements pantry strip subcommand
# VERSION

use Pantry::App -command;
use autodie;

use namespace::clean;

sub abstract {
  return 'Strip recipes or attributes from a node'
}

sub command_type {
  return 'TARGET';
}

sub valid_types {
  return qw/node role/
}

sub options {
  my ($self) = @_;
  return $self->data_options;
}

sub _strip_node {
  my ($self, $opt, $name) = @_;
  $self->_strip_obj($opt, 'node', $name);
}

sub _strip_role {
  my ($self, $opt, $name) = @_;
  $self->_strip_obj($opt, 'role', $name);
}

my %strippers = (
  node => {
    default => 'delete_attribute',
    override => undef,
  },
  role => {
    default => 'delete_default_attribute',
    override => 'delete_override_attribute',
  },
);

sub _strip_obj {
  my ($self, $opt, $type, $name) = @_;

  my $obj = $self->_check_name($type, $name);

  $self->_delete_runlist($obj, $opt);

  for my $k ( sort keys %{$strippers{$type}} ) {
    if ( my $method = $strippers{$type}{$k} ) {
      $self->_delete_attributes($obj, $opt, $k, $method);
    }
    else {
      $k = ucfirst $k;
      warn "$k attributes do not apply to $type objects.  Skipping them.\n";
    }
  }

  $obj->save;
  return;
}

sub _check_name {
  my ($self, $type, $name) = @_;
  my $obj = $self->pantry->$type( $name )
    or $self->usage_error( "$type '$name' does not exist" );
  return $obj;
}

sub _delete_runlist{
  my ($self, $obj, $opt) = @_;
  if ($opt->{role}) {
    $obj->remove_from_run_list(map { "role[$_]" } @{$opt->{role}});
  }
  if ($opt->{recipe}) {
    $obj->remove_from_run_list(map { "recipe[$_]" } @{$opt->{recipe}});
  }
  return;
}

sub _delete_attributes {
  my ($self, $obj, $opt, $which, $method) = @_;
  if ($opt->{$which}) {
    for my $attr ( @{ $opt->{$which} } ) {
      my ($key, $value) = split /=/, $attr, 2; # split on first '='
      # if they gave a value, we ignore it
      $obj->$method($key);
    }
  }
  return;
}


1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry strip node foo.example.com --recipe nginx --default nginx.port

=head1 DESCRIPTION

This class implements the C<pantry strip> command, which is used to strip recipes or attributes
from a node.

=cut

# vim: ts=2 sts=2 sw=2 et:
