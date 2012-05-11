use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

my @cases = (
  {
    label => "node",
    type => "node",
    name => 'foo.example.com',
    new => sub { my ($p,$n) = @_; $p->node($n) },
  },
  {
    label => "role",
    type => "role",
    name => 'web',
    new => sub { my ($p,$n) = @_; $p->role($n) },
  },
);

local $ENV{PERL_MM_USE_DEFAULT} = 1;

for my $c ( @cases ) {
  subtest "$c->{label}: try delete, but don't confirm" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});
    _try_command('create', $c->{type}, $c->{name});
    _try_command('delete', $c->{type}, $c->{name});
    ok( -e $obj->path, "$c->{type} '$c->{name}' not deleted" );
  };

  subtest "$c->{label}: try delete, with force" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});
    _try_command('create', $c->{type}, $c->{name});
    _try_command('delete', '-f', $c->{type}, $c->{name});
    ok( ! -e $obj->path, "$c->{type} '$c->{name}' delete" );
  };

  subtest "$c->{label}: delete a missing node" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $result = _try_command('delete', $c->{type}, $c->{name}, { exit_code => -1});
    like( $result->error, qr/does not exist/, "error message" );
  };
}



done_testing;
# COPYRIGHT
