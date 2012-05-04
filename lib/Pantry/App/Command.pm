use v5.14;
use warnings;

package Pantry::App::Command;
# ABSTRACT: Pantry command superclass
# VERSION

use App::Cmd::Setup -command;

#--------------------------------------------------------------------------#
# global behaviors
#--------------------------------------------------------------------------#

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

sub pantry {
  my $self = shift;
  require Pantry::Model::Pantry;
  $self->{pantry} ||= Pantry::Model::Pantry->new;
  return $self->{pantry};
}

#--------------------------------------------------------------------------#
# override in subclasses to customize
#--------------------------------------------------------------------------#

sub options {
  return;
}

sub validate{
  return;
}

#--------------------------------------------------------------------------#
# help boilerplate
#--------------------------------------------------------------------------#

my %help_types = (
  DEFAULT => {
    usage => "%c CMD [OPTIONS]",
    target_desc => '',
  },
  TYPE => {
    usage => "%c CMD <TYPE> [OPTIONS]",
    target_desc => << 'HERE',
The TYPE parameter indicates what kind of pantry object to list.
Valid types include:

        node, nodes   lists nodes
HERE
  },
  TARGET => {
    usage => "%c CMD <TARGET> [OPTIONS]",
    target_desc => << 'HERE',
The TARGET parameter consists of a TYPE and a NAME separated by whitespace.

The TYPE indicates what kind of pantry object to operate on and the NAME
indicates which specific one. (e.g. "node foo.example.com")

Valid TARGET types include:

        node      NAME must be a node name in the pantry
HERE
  },
  DUAL_TARGET => {
    usage => "%c CMD <TARGET> <DESTINATION> [OPTIONS]",
    target_desc => << 'HERE',
The TARGET parameter consists of a TYPE and a NAME separated by whitespace.

The TYPE indicates what kind of pantry object to operate on and the NAME
indicates which specific one. (e.g. "node foo.example.com")

Valid TARGET types include:

        node      NAME must be a node name in the pantry

The DESTINATION parameter indicates where the NAME should be put.
HERE
  },
  CREATE => {
    usage => "%c CMD <TARGET> [OPTIONS]",
    target_desc => << 'HERE',
The TARGET parameter consists of a TYPE and a NAME separated by whitespace.

The TYPE indicates what kind of pantry object to operate on and the NAME
indicates which specific one. (e.g. "node foo.example.com")

Valid TARGET types include:

        node      NAME must be a node name that is *NOT* in the pantry
HERE
  },
);

sub help_type {
  return 'DEFAULT';
}

sub usage_desc {
  my ($self) = shift;
  my ($cmd) = $self->command_names;
  my $usage = $help_types{$self->help_type}{usage};
  $usage =~ s/CMD/$cmd/;
  return $usage;
}

sub description {
  my ($self) = @_;
  my $target = $help_types{$self->help_type}{target_desc};
  return join("\n",
    $self->abstract . ".\n", ($target ? $target : ()), $self->options_desc
  );
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
