use v5.14;
use warnings;

package Pantry::App::Command;
# ABSTRACT: Pantry command superclass
# VERSION

use App::Cmd::Setup -command;

sub opt_spec {
  my ($class, $app) = @_;
  # XXX should these be sorted on long name? -- xdg, 2012-05-03
  return (
    $class->options($app),
    # Universal
    [ 'help|h' => "This usage screen" ],
  )
}

sub validate_args {
  my ( $self, $opt, $args ) = @_;
  if ( $opt->{help} ) {
    my ($command) = $self->command_names;
    $self->app->execute_command(
      $self->app->prepare_command("help", $command)
    );
    exit 0;
  }
  $self->validate( $opt, $args );
}

sub usage_desc {
  my ($self) = shift;
  my ($cmd) = $self->command_names;
  return "%c $cmd [OPTIONS]"
}

sub target_usage {
  my ($self) = shift;
  my ($cmd) = $self->command_names;
  return "%c $cmd <TARGET> [OPTIONS]"
}

sub description {
  my ($self) = @_;
  return join("\n", $self->abstract . ".\n", $self->options_desc);
}

sub target_description {
  my ($self) = @_;
  return join("\n", $self->abstract . ".\n", $self->target_desc, $self->options_desc);
}

sub target_desc {
  my ($self) = @_;
  return << 'HERE';
The TARGET parameter consists of a TYPE and a NAME separated by whitespace.

The TYPE indicates what kind of pantry object to operate on and the NAME
indicates which specific one. (e.g. "node foo.example.com")

Valid TARGET types include:

        node      NAME must be a node name in the pantry
HERE
}

sub options_desc {
  my ($self) = @_;
  return << 'HERE';
OPTIONS parameters provide additional data or modify how the command
runs.  Valid options include:
HERE
}

sub data_options {
  return (
    [ 'recipe|r=s@' => "A recipe (without 'recipe[...]')" ],
    [ 'default|d=s@' => "Default attribute (as KEY or KEY=VALUE)" ],
  );
}

sub pantry {
  my $self = shift;
  require Pantry::Model::Pantry;
  $self->{pantry} ||= Pantry::Model::Pantry->new;
  return $self->{pantry};
}

1;

=for Pod::Coverage
data_options
options_desc
pantry
target_desc
target_description
target_usage


=head1 DESCRIPTION

This internal implementation class defines common command line options
and provides methods needed by all command subclasses.

=cut

# vim: ts=2 sts=2 sw=2 et:
