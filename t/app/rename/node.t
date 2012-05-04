use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;
use Pantry::Model::Pantry;

subtest "rename a node" => sub {
  my ($wd, $pantry) = _create_node("foo.example.com");
  _try_command(qw(rename node foo.example.com bar.example.com));
  ok( ! -e $pantry->node("foo.example.com")->path, "foo.example.com is gone" );
  ok( -e $pantry->node("bar.example.com")->path, "bar.example.com exists" );
};

subtest "rename missing node" => sub {
  my ($wd, $pantry) = _create_pantry();
  my $result = _try_command(qw(rename node foo.example.com bar.example.com), { exit_code => -1});
  like( $result->error, qr/doesn't exist/, "error message" );
  ok( ! -e $pantry->node("foo.example.com")->path, "foo.example.com not there" );
  ok( ! -e $pantry->node("bar.example.com")->path, "bar.example.com not there" );
};

subtest "rename won't clobber" => sub {
  my ($wd, $pantry) = _create_node("foo.example.com");
  _try_command(qw/create node bar.example.com/);
  my $result = _try_command(qw(rename node foo.example.com bar.example.com), { exit_code => -1});
  like( $result->error, qr/already exists/, "error message" );
  ok( -e $pantry->node("foo.example.com")->path, "foo.example.com is there" );
  ok( -e $pantry->node("bar.example.com")->path, "bar.example.com is there" );
};
done_testing;
# COPYRIGHT
