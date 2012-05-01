use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use File::pushd 1.00 qw/tempd/;

use App::Cmd::Tester::CaptureExternal;
use Pantry::App;
use Pantry::Model::Pantry;
use JSON;
use File::Slurp qw/read_file/;

sub _thaw_file {
  my $file = shift;
  my $guts = scalar read_file( $file );
  my $data = eval { decode_json( $guts ) };
  die if $@;
  return $data;
}

sub _dump_node {
  my $node = shift;
  my $path = $node->_path;
  diag "File contents of " . $node->name . ":\n" . join("", explain _thaw_file($path));
}

sub _try_command {
  my @command = @_;
  my $result = test_app( 'Pantry::App' => [@command] );
  is( $result->exit_code, 0, "'pantry @command'" )
    or diag $result->output || $result->error;
}

sub _create_node {
  my $wd = tempd;
  _try_command(qw(init));
  _try_command(qw(create node foo.example.com));

  my $pantry = Pantry::Model::Pantry->new( path => "$wd" );
  my $node = $pantry->node("foo.example.com");
  if ( -e $node->_path ) {
    pass("test node file found");
  }
  else {
    fail("test node file found");
    diag("node foo.example.com not found at " . $node->_path);
    diag("bailing out of rest of the subtest");
    return;
  }

  return ($wd, $pantry);
}

subtest "apply recipe" => sub {
  my ($wd, $pantry) = _create_node or return;

  _try_command(qw(apply node foo.example.com -r nginx));

  my $node = $pantry->node("foo.example.com");
  is_deeply( [$node->run_list], [ 'recipe[nginx]' ], "apply -r nginx successful" )
    or diag explain $node;
};


subtest "apply attribute" => sub {
  my ($wd, $pantry) = _create_node or return;
  _try_command(qw(apply node foo.example.com -d nginx.port=80));

  my $node = $pantry->node("foo.example.com")
    or BAIL_OUT "Couldn't get node for testing";
  is( $node->get_attribute('nginx.port'), 80, "attribute set successfully" )
    or _dump_node($node);
};

subtest "apply list attribute" => sub {
  my ($wd, $pantry) = _create_node or return;
  _try_command(qw(apply node foo.example.com -d nginx.port=80,8080));

  my $node = $pantry->node("foo.example.com")
    or BAIL_OUT "Couldn't get node for testing";
  is_deeply( $node->get_attribute('nginx.port'), [80,8080], "list attribute set successfully" )
    or _dump_node($node);
};

subtest "apply attributes with escapes" => sub {
  my ($wd, $pantry) = _create_node or return;
  _try_command(qw(apply node foo.example.com -d nginx\.port=80,8000\,8080));

  my $node = $pantry->node("foo.example.com")
    or BAIL_OUT "Couldn't get node for testing";
  is_deeply( $node->get_attribute('nginx\.port'), [80,'8000,8080'], "attributes with escapes set successfully" )
    or _dump_node($node);
};

done_testing;
# COPYRIGHT
