use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;
use Pantry::Model::Pantry;

local $ENV{PERL_MM_USE_DEFAULT} = 1;

subtest "try delete, but don't confirm" => sub {
  my ($wd, $pantry) = _create_node("foo.example.com");
  _try_command(qw(delete node foo.example.com));
  ok( -e $pantry->node("foo.example.com")->path, "foo.example.com not deleted" );
};

subtest "try delete, with force" => sub {
  my ($wd, $pantry) = _create_node("foo.example.com");
  _try_command(qw(delete -f node foo.example.com));
  ok( ! -e $pantry->node("foo.example.com")->path, "foo.example.com deleted" );
};

subtest "delete a missing node" => sub {
  my ($wd, $pantry) = _create_pantry();
  my $result = _try_command(qw(delete node foo.example.com), { exit_code => -1});
  like( $result->error, qr/doesn't exist/, "error message" );
};

done_testing;
# COPYRIGHT
