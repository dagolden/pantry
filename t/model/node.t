use 5.006;
use strict;
use warnings;
use Test::More 0.96;
use File::pushd qw/tempd/;

use Pantry::Model::Node;

# creation
subtest "creation" => sub {
  new_ok("Pantry::Model::Node", [name => "foo.example.com"]);
};

# create/serialize/deserialize
subtest "freeze/thaw" => sub {
  my $wd=tempd;

  my $node = Pantry::Model::Node->new(name => "foo.example.com");
  ok( $node->save_as("node.json"), "saved a node" );
  ok( my $thawed = Pantry::Model::Node->new_from_file("node.json"), "thawed node");
  is( $thawed->name, $node->name, "thawed name matches original name" );
};

# create with a path
subtest "_path attribute" => sub {
  my $wd=tempd;

  my $node = Pantry::Model::Node->new(
    name => "foo.example.com",
    _path => "node.json"
  );
  ok( $node->save, "saved a node with default path" );
  ok( my $thawed = Pantry::Model::Node->new_from_file("node.json"), "thawed node");
  is( $thawed->name, $node->name, "thawed name matches original name" );
};

# runlist manipulation
subtest 'append to / remove from runlist' => sub {
  my $node = Pantry::Model::Node->new(
    name => "foo.example.com",
  );
  $node->append_to_runlist( "foo", "bar" );
  is_deeply([qw/foo bar/], [$node->run_list], "append two items");
  $node->append_to_runlist( "baz" );
  is_deeply([qw/foo bar baz/], [$node->run_list], "append another");
  $node->remove_from_runlist("bar");
  is_deeply([qw/foo baz/], [$node->run_list], "remove from middle");
  $node->remove_from_runlist("wibble");
  is_deeply([qw/foo baz/], [$node->run_list], "remove item that doesn't exist");
};

done_testing;
# COPYRIGHT
