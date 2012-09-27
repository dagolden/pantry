use v5.14;
use warnings;

package Pantry::App::Command::create;
# ABSTRACT: Implements pantry create subcommand
# VERSION

use Pantry::App -command;
use autodie;

use namespace::clean;

sub abstract {
  return 'Create items in a pantry (nodes, roles, etc.)';
}

sub command_type {
  return 'CREATE';
}

sub options {
  my ($self) = @_;
  return ($self->ssh_options, $self->selector_options);
}

# These get auto-generated creator methods
my %creators = (
  role => 'save',
  environment => 'save',
  bag => 'save',
  cookbook => 'create_boilerplate',
);

# Nodes get custom processing
sub valid_types {
  return qw/node/, keys %creators;
}

while ( my ($type, $method) = each %creators ) {
  no strict 'refs';
  *{"_create_$type"} = sub {
    my ($self, $opt, $name) = @_;
    return $self->_generic_create($name, $type, $method);
  };
}

sub _create_node {
  my ($self, $opt, $name) = @_;

  my %options;
  for my $k ( qw/host port user/ ) {
    $options{"pantry_$k"} = $opt->$k if $opt->$k;
  }
  $options{env} = $opt->{env} if $opt->{env};

  return $self->_generic_create($name, 'node', 'save', \%options);
}

sub _generic_create {
  my ($self, $name, $type, $init, $options ) = @_;

  my $obj = $self->pantry->$type( $name, $options );
  if ( -e $obj->path ) {
    $type = uc $type;
    $self->usage_error( "$type '$name' already exists" );
  }
  else {
    $obj->$init;
  }

  return $obj;
}
1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry create node foo.example.com

=head1 DESCRIPTION

This class implements the C<pantry create> command, which is used to create a new node data file
in a pantry.

=cut

# vim: ts=2 sts=2 sw=2 et:
