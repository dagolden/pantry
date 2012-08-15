use v5.14;
use warnings;

package Pantry::App::Command::edit;
# ABSTRACT: Implements pantry edit subcommand
# VERSION

use Pantry::App -command;
use autodie;
use File::Basename qw/dirname basename/;
use File::Slurp qw/read_file/;
use IPC::Cmd qw/can_run/;
use JSON qw/decode_json/;

use namespace::clean;

sub abstract {
  return 'Edit items in a pantry (nodes, roles, etc.)';
}

sub command_type {
  return 'TARGET';
}

sub options {
  my ($self) = @_;
  return ($self->selector_options);
}

sub valid_types {
  return qw/node role environment/
}

sub _edit_node {
  my ($self, $opt, $name) = @_;
  $self->_edit_obj($opt, 'node', $name);
}

sub _edit_role {
  my ($self, $opt, $name) = @_;
  $self->_edit_obj($opt, 'role', $name);
}

sub _edit_environment {
  my ($self, $opt, $name) = @_;
  $self->_edit_obj($opt, 'environment', $name);
}

sub _edit_obj {
  my ($self, $opt, $type, $name) = @_;

  my @editor = defined $ENV{EDITOR} ? split / /, $ENV{EDITOR} : ();
  if ( @editor && (my $bin = can_run($editor[0])) ) {
    $editor[0] = $bin;
  }
  else {
    $self->usage_error( "EDITOR not set or not found" );
  }

  my $options;
  $options->{env} = $opt->{env} if $opt->{env};

  my $obj = $self->_check_name($type, $name, $options);

  my $path = $obj->path;

  if ( -e $path ) {
    system( @editor, $path ) and die "System failed!: $!";
    eval { decode_json(read_file($path,{ binmode => ":raw" })) };
    if ( my $err = $@ ) {
      $err =~ s/, at .* line .*//;
      warn "Warning: JSON errors in config for $name\n";
    }
  }
  else {
    $type = ucfirst $type;
    $self->usage_error("$type '$name' does not exist");
  }
}

1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry edit node foo.example.com

=head1 DESCRIPTION

This class implements the C<pantry edit> command, which is used to open the node data
JSON file in an editor for direct editing.

=cut

# vim: ts=2 sts=2 sw=2 et:
