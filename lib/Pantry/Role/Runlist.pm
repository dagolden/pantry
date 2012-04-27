use v5.14;
use strict;
use warnings;
package Pantry::Role::Runlist;
# ABSTRACT: A role to manage entries in a runlist
# VERSION

use Moose::Role;
use namespace::autoclean;

has run_list => (
  is => 'bare',
  isa => 'ArrayRef[Str]',
  traits => ['Array'],
  default => sub { [] },
  handles => {
    run_list => 'elements',
    _push_run_list => 'push',
    _clear_run_list => 'clear',
  },
);

sub in_run_list {
  my ($self, $item) = @_;
  return grep { $item eq $_ } $self->run_list;
}

sub append_to_runlist {
  my ($self, @items) = @_;
  for my $i (@items) {
    $self->_push_run_list($i)
      unless $self->in_run_list($i);
  }
  return;
}

sub remove_from_runlist {
  my ($self, @items) = @_;
  my %match = map { $_ => 1 } @items;
  my @keep = grep { ! $match{$_} } $self->run_list;
  $self->_clear_run_list;
  $self->_push_run_list(@keep);
  return;
}

1;

