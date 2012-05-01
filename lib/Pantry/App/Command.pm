use v5.14;
use warnings;

package Pantry::App::Command;
# ABSTRACT: Implements common command options
# VERSION

use App::Cmd::Setup -command;

sub opt_spec {
  my ($class, $app) = @_;
    return (
    # Universal
    [ 'help' => "This usage screen" ],
    # Selectors/qualifiers
    [ 'recipe|r=s@' => "A recipe" ],
    $class->options($app),
  )
}
 
sub validate_args {
  my ( $self, $opt, $args ) = @_;
  die $self->_usage_text if $opt->{help};
  $self->validate( $opt, $args );
}

sub pantry {
  require Pantry::Model::Pantry;
  state $pantry = Pantry::Model::Pantry->new;
  return $pantry;
}

1;

# vim: ts=2 sts=2 sw=2 et:
