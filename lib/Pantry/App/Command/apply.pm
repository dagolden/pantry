use v5.14;
use warnings;

package Pantry::App::Command::apply;
# ABSTRACT: Implements pantry apply subcommand
# VERSION

use Pantry::App -command;
use autodie;

use namespace::clean;

sub abstract {
  return 'Apply recipes or attributes to a node or role'
}

sub command_type {
  return 'TARGET';
}

sub options {
  my ($self) = @_;
  return $self->data_options;
}

sub valid_types {
  return qw/node role/
}

sub _apply_node {
  my ($self, $opt, $name) = @_;
  $self->_apply_obj($opt, 'node', $name);
}

sub _apply_role {
  my ($self, $opt, $name) = @_;
  $self->_apply_obj($opt, 'role', $name);
}

my %setters = (
  node => {
    default => 'set_attribute',
    override => undef,
  },
  role => {
    default => 'set_default_attribute',
    override => 'set_override_attribute',
  },
);

sub _apply_obj {
  my ($self, $opt, $type, $name) = @_;

  my $obj = $self->_check_name($type, $name);

  $self->_apply_runlist($obj, $opt);

  for my $k ( sort keys %{$setters{$type}} ) {
    if ( my $method = $setters{$type}{$k} ) {
      $self->_set_attributes($obj, $opt, $k, $method);
    }
    elsif ( $opt->{$k} ) {
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

sub _apply_runlist {
  my ($self, $obj, $opt) = @_;
  if ($opt->{role}) {
    $obj->append_to_run_list(map { "role[$_]" } @{$opt->{role}});
  }
  if ($opt->{recipe}) {
    $obj->append_to_run_list(map { "recipe[$_]" } @{$opt->{recipe}});
  }
  return;
}

sub _set_attributes {
  my ($self, $obj, $opt, $which, $method) = @_;
  if ($opt->{$which}) {
    for my $attr ( @{ $opt->{$which} } ) {
      my ($key, $value) = split /=/, $attr, 2; # split on first '='
      if ( $value =~ /(?<!\\),/ ) {
        # split on unescaped commas, then unescape escaped commas
        $value = [ map { s/\\,/,/gr } split /(?<!\\),/, $value ];
      }
      $obj->$method($key, $value);
    }
  }
  return;
}


1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry apply node foo.example.com --recipe nginx --default nginx.port=8080

=head1 DESCRIPTION

This class implements the C<pantry apply> command, which is used to apply recipes or attributes
to a node.

=cut

# vim: ts=2 sts=2 sw=2 et:
