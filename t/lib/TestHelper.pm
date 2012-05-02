use 5.010;
use strict;
use warnings;
package TestHelper;

use parent 'Exporter';
our @EXPORT = qw(
  _thaw_file
  _dump_node
  _try_command
  _create_node
);

use App::Cmd::Tester::CaptureExternal;
use File::Slurp qw/read_file/;
use File::pushd 1.00 qw/tempd/;
use JSON;
use Test::More;
use Pantry::App;
use Pantry::Model::Pantry;

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


1;

