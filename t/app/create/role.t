use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

my $empty = {
  run_list => [],
};


{
  my ($wd, $pantry) = _create_pantry();

  ok( ! -e $pantry->role("web")->path, "role 'web' not created yet" );

  _try_command(qw/create role web/);

  ok( -e $pantry->role("web")->path, "role 'web' created" );

}

done_testing;
# COPYRIGHT
