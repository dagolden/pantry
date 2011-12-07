use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use File::pushd 1.00 qw/tempd/;
use App::Cmd::Tester;
use Pantry::App;

#--------------------------------------------------------------------------#
# create single node
#--------------------------------------------------------------------------#-

{
  my $wd = tempd;

  my $result = test_app( 'Pantry::App' => [qw(init)] );
  $result->error and BAIL_OUT("Could not initialize pantry in $wd");
  pass( "Created test pantry" );

  my $node_file = 'environments/_default/foo.example.com.json';
  ok( ! -e $node_file, "No node file exists yet" );
  $result = test_app( 'Pantry::App' => [qw(create node foo.example.com)] );
  is( $result->error, undef, "Ran 'pantry create node ...' without error" )
    or diag $result->output;
  ok( -f $node_file, "Node file has been created" );
}

done_testing;
# COPYRIGHT
