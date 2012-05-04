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

subtest "list nodes when empty" => sub {
  my $pantry = _new_pantry_ok();
  is( scalar $pantry->all_nodes, 0, "all_nodes gives count of 0 (scalar)" );
  is_deeply( [$pantry->all_nodes], [], "all_nodes gives empty list (list)" );
};

subtest "node are lower case" => sub {
  my $pantry = _new_pantry_ok();
  ok( my $node = $pantry->node("FOO.example.com"), "created a node");
  is( $node->name, lc $node->name, "node name is lc" );
  is( $node->path->basename, lc $node->path->basename, "node basename is lc" );
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

subtest "list nodes when some exist" => sub {
  my $pantry = _new_pantry_ok();
  ok( $pantry->node("foo.example.com")->save, "created a node");
  ok( $pantry->node("foo2.example.com")->save, "created another node");
  is( scalar $pantry->all_nodes, 2, "all_nodes gives count of 2 (scalar)" );
  is_deeply( [sort $pantry->all_nodes], [sort qw/foo.example.com foo2.example.com/],
    "all_nodes gives correct list (list)"
  );
};

done_testing;
# COPYRIGHT
