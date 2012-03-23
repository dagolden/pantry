use v5.14;
use strict;
use warnings;
package Pantry::Role::Serializable;
# ABSTRACT: A role to save/load data to/from JSON files
# VERSION

use MooseX::Role::Parameterized;
use Moose::Util qw/get_all_attribute_values/;
use namespace::autoclean;

use Class::Load qw/load_class/;
use File::Basename qw/dirname/;
use File::Path qw/mkpath/;
use File::Slurp qw/read_file write_file/;
use JSON 2;

parameter engine => (
  isa => 'Str',
  required => 1,
);

parameter engine_opts => (
  isa => 'HashRef',
  default => sub { return {} },
);

role {
  my $params = shift;
  my $engine_class = "Pantry::Role::Serializable::" . $params->engine;
  load_class $engine_class;
  my $engine = $engine_class->new( engine_opts => $params->engine_opts );

  method new_from_file => sub {
    my ($class, $file) = @_;

    my $str_ref = read_file( $file, { binmode => ":raw", scalar_ref => 1 } );

    # XXX check if string needs UTF-8 decoding?
    my $data = $engine->thaw( $str_ref );

    return $class->new( $data );
  };

  method save_as => sub {
    my ($self, $file) = @_;

    my $data = get_all_attribute_values($self->meta, $self);
    delete $data->{$_} for grep { /^_/ } keys %$data; # delete private attributes

    # XXX check if string needs UTF-8 encoding?
    my $str_ref = $engine->freeze( $data );

    mkpath( dirname( $file ) );
    return write_file( $file, { binmode => ":raw", atomic => 1 }, $str_ref );
  };

};

1;

