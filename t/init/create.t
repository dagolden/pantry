use 5.006;
use strict;
use warnings;
use Test::More 0.92;

use File::pushd 1.00 qw/tempd/;
use App::Cmd::Tester;
use Pantry::App;

my @created_dirs = qw(
  cookbooks
  roles
  environments
);

{
  my $wd = tempd;
  for my $d ( @created_dirs ) {
    ok( ! -e $d, "Before: $d does not exist" );
  }

  my $result = test_app( 'Pantry::App' => [qw(init)] );
  is( $result->error, undef, "Ran without error" );

  for my $d ( @created_dirs ) {
    ok( -d $d, "After: $d directory created" );
    like( $result->stdout, qr/\Q$d\E/, "After: $d creation message seen" );
  }
}

done_testing;
# COPYRIGHT
