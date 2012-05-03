use v5.14;
use warnings;

package Pantry::App::Command;
# ABSTRACT: Pantry command superclass
# VERSION

use App::Cmd::Setup -command;

sub opt_spec {
  my ($class, $app) = @_;
    return (
    # Universal
    [ 'help' => "This usage screen" ],
    # Selectors/qualifiers
    [ 'recipe|r=s@' => "A recipe" ],
    [ 'default|d=s@' => "Default attribute" ],
    $class->options($app),
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

1;

=for Pod::Coverage pantry

=head1 DESCRIPTION

This internal implementation class defines common command line options
and provides methods needed by all command subclasses.

=cut

# vim: ts=2 sts=2 sw=2 et:
