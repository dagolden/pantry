use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use File::pushd 1.00 qw/tempd/;

use App::Cmd::Tester::CaptureExternal;
use Pantry::App;
use Pantry::Model::Pantry;

sub _create_node {
  my $wd = tempd;
  my $pantry = Pantry::Model::Pantry->new( path => "$wd" );

  my $result = test_app( 'Pantry::App' => [qw(init)] );
  $result->error and BAIL_OUT("could not initialize pantry in $wd");
  pass( "created test pantry" );

  $result = test_app( 'Pantry::App' => [qw(create node foo.example.com)] );
  $result->error and BAIL_OUT("could not create node foo.example.com");
  pass( "created test node" );

  return ($wd, $pantry);
}

subtest "apply recipe" => sub {
  my ($wd, $pantry) = _create_node;

  my $result = test_app( 'Pantry::App' => [qw(apply node foo.example.com -r nginx)] );

  is( $result->exit_code, 0, "ran 'pantry apply node -r nginx' without error" )
    or diag $result->output;

  my $node = $pantry->node("foo.example.com");
  is_deeply( [$node->run_list], [ 'recipe[nginx]' ], "apply -r nginx successfule" );
};

done_testing;
# COPYRIGHT
