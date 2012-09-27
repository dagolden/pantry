use 5.006;
use strict;
use warnings;
use Test::More 0.96;
use File::pushd qw/tempd/;

use lib 't/lib';
use TestHelper;

use Pantry::Model::DataBag;

# creation
subtest "creation" => sub {
  new_ok("Pantry::Model::DataBag", [name => "xdg"]);
};

# create/serialize/deserialize
subtest "freeze/thaw" => sub {
  my $wd=tempd;

  my $bag = Pantry::Model::DataBag->new(name => "web");
  ok( $bag->save_as("bag.json"), "saved a bag" );
  ok( my $thawed = Pantry::Model::DataBag->new_from_file("bag.json"), "thawed bag");
  is( $thawed->name, $bag->name, "thawed name matches original name" );
};

# create with a path
subtest "_path attribute" => sub {
  my $wd=tempd;

  my $bag = Pantry::Model::DataBag->new(
    name => "xdg",
    _path => "bag.json"
  );
  ok( $bag->save, "saved a bag with default path" );
  ok( my $thawed = Pantry::Model::DataBag->new_from_file("bag.json"), "thawed bag");
  is( $thawed->name, $bag->name, "thawed name matches original name" );
};

### runlist manipulation
##subtest 'append to / remove from runlist' => sub {
##  my $bag = Pantry::Model::DataBag->new(
##    name => "web",
##  );
##  $bag->append_to_run_list( "foo", "bar" );
##  is_deeply([qw/foo bar/], [$bag->run_list], "append two items");
##  $bag->append_to_run_list( "baz" );
##  is_deeply([qw/foo bar baz/], [$bag->run_list], "append another");
##  $bag->remove_from_run_list("bar");
##  is_deeply([qw/foo baz/], [$bag->run_list], "remove from middle");
##  $bag->remove_from_run_list("wibble");
##  is_deeply([qw/foo baz/], [$bag->run_list], "remove item that doesn't exist");
##};
##
##subtest 'bag default attribute CRUD' => sub {
##  my $bag = Pantry::Model::DataBag->new(
##    name => "web",
##  );
##  $bag->set_default_attribute("nginx.port" => 80);
##  is( $bag->get_default_attribute("nginx.port"), 80, "set/got 'nginx.port'" );
##  $bag->set_default_attribute("nginx.port" => 8080);
##  is( $bag->get_default_attribute("nginx.port"), 8080, "changed 'nginx.port'" );
##  $bag->delete_default_attribute("nginx.port");
##  is( $bag->get_default_attribute("nginx.port"), undef, "deleted 'nginx.port'" );
##};
##
##subtest 'bag override attribute CRUD' => sub {
##  my $bag = Pantry::Model::DataBag->new(
##    name => "web",
##  );
##  $bag->set_override_attribute("nginx.port" => 80);
##  is( $bag->get_override_attribute("nginx.port"), 80, "set/got 'nginx.port'" );
##  $bag->set_override_attribute("nginx.port" => 8080);
##  is( $bag->get_override_attribute("nginx.port"), 8080, "changed 'nginx.port'" );
##  $bag->delete_override_attribute("nginx.port");
##  is( $bag->get_override_attribute("nginx.port"), undef, "deleted 'nginx.port'" );
##};
##
##subtest 'bag attribute serialization' => sub {
##  my $wd=tempd;
##  my $bag = Pantry::Model::DataBag->new(
##    name => "web",
##    _path => "bag.json",
##  );
##  $bag->set_default_attribute("nginx.port" => 80);
##  $bag->set_default_attribute("nginx.user" => "nobody");
##  $bag->set_override_attribute("set_fqdn" => "web");
##  $bag->save;
##  my $data = _thaw_file("bag.json");
##  is_deeply( $data, {
##      name => 'web',
##      json_class => 'Chef::DataBag',
##      chef_type => 'bag',
##      run_list => [],
##      env_run_lists => {},
##      default_attributes => {
##        nginx => {
##          port => 80,
##          user => "nobody",
##        },
##      },
##      override_attributes => {
##        set_fqdn => "web",
##      },
##    },
##    "bag attributes serialized at correct level"
##  ) or diag explain $data;
##  ok( my $thawed = Pantry::Model::DataBag->new_from_file("bag.json"), "thawed bag");
##  my $err;
##  is( $thawed->get_default_attribute("nginx.port"), 80, "thawed bag has correct default 'nginx.port'" )
##    or $err++;
##  is( $thawed->get_default_attribute("nginx.user"), "nobody", "thawed bag has correct default 'nginx.user'" )
##    or $err++;
##  is( $thawed->get_override_attribute("set_fqdn"), "web", "thawed bag has correct override 'set_fqdn'" )
##    or $err++;
##  diag "DATA FILE:\n", explain $data if $err;
##};
##
##subtest 'bag attribute escape dots' => sub {
##  my $wd=tempd;
##  my $bag = Pantry::Model::DataBag->new(
##    name => "web",
##    _path => "bag.json",
##  );
##  $bag->set_default_attribute('nginx\.port' => 80);
##  $bag->set_override_attribute('deep.attribute.dotted\.name' => 'bar');
##  is( $bag->get_default_attribute('nginx\.port'), 80, q{set/got 'nginx\.port'} );
##  is( $bag->get_override_attribute('deep.attribute.dotted\.name'), 'bar', q{set/got 'deep.attribute.dotted\.name'} );
##  $bag->save;
##  my $data = _thaw_file("bag.json");
##  is_deeply( $data, {
##      name => 'web',
##      json_class => 'Chef::DataBag',
##      chef_type => 'bag',
##      run_list => [],
##      env_run_lists => {},
##      default_attributes => {
##        'nginx.port' => 80,
##      },
##      override_attributes => {
##        'deep' => {
##          attribute => {
##            'dotted.name' => 'bar',
##          },
##        },
##      },
##    },
##    "bag attributes escaped dot works"
##  ) or diag explain $data;
##  ok( my $thawed = Pantry::Model::DataBag->new_from_file("bag.json"), "thawed bag");
##  is( $thawed->get_default_attribute('nginx\.port'), 80, q{thawed bag has correct 'nginx\.port'} )
##    or diag explain $thawed;
##  is( $thawed->get_override_attribute('deep.attribute.dotted\.name'), 'bar', q{thawed bag has correct 'deep.attribute.dotted\.name'} )
##    or diag explain $thawed;
##};
##
##subtest 'append to / remove from environment runlist' => sub {
##  my $wd=tempd;
##  my $bag = Pantry::Model::DataBag->new(
##    name => "web",
##    _path => "bag.json",
##  );
##  $bag->append_to_env_run_list( 'test', ["foo", "bar"] );
##  is_deeply([qw/foo bar/], [$bag->get_env_run_list('test')->run_list], "append two items to test environment");
##  $bag->append_to_env_run_list( 'test', ["baz"] );
##  is_deeply([qw/foo bar baz/], [$bag->get_env_run_list('test')->run_list], "append another");
##  $bag->remove_from_env_run_list('test', ["bar"]);
##  is_deeply([qw/foo baz/], [$bag->get_env_run_list('test')->run_list], "remove from middle");
##  $bag->remove_from_run_list('test', ["wibble"]);
##  is_deeply([qw/foo baz/], [$bag->get_env_run_list('test')->run_list], "remove item that doesn't exist");
##  $bag->save;
##  my $data = _thaw_file("bag.json");
##  is_deeply( $data, {
##      name => 'web',
##      json_class => 'Chef::DataBag',
##      chef_type => 'bag',
##      run_list => [],
##      env_run_lists => {
##        test => [qw/foo baz/],
##      },
##      default_attributes => {},
##      override_attributes => {},
##    },
##    "env_run_lists serialized correctly"
##  ) or diag explain $data;
##  ok( my $thawed = Pantry::Model::DataBag->new_from_file("bag.json"), "thawed bag");
##  is_deeply([qw/foo baz/], [$thawed->get_env_run_list('test')->run_list], "env_run_lists round-tripped correctly");
##};

done_testing;
# COPYRIGHT
