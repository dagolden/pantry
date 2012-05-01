use 5.006;
use strict;
use warnings;
use Test::More 0.96;
use File::pushd qw/tempd/;
use File::Slurp qw/read_file/;
use Path::Class;
use JSON;
use File::Temp;

use Pantry::Model::Pantry;

my @temps;
sub _new_pantry_ok {
  push @temps, File::Temp->newdir;
  return new_ok("Pantry::Model::Pantry", [path => $temps[-1]]);
}

subtest "constructor" => sub {
  _new_pantry_ok();
};

subtest "create/retrieve a node" => sub {
  my $pantry = _new_pantry_ok();
  ok( my $node = $pantry->node("foo.example.com"), "created a node");
  $node->save;
  ok( -e file( $pantry->path =>, 'environments', '_default', 'foo.example.com.json'),
      "saved a node"
  );
  ok( my $node2 = $pantry->node("foo.example.com"), "retrieved a node");
  ok( $node2->save, "saved it again" );
};

done_testing;
# COPYRIGHT
