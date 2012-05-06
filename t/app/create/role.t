use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

my $empty = {
  json_class => "Chef::Role",
  chef_type => "role",
  run_list => [],
};

{
  my ($wd, $pantry) = _create_pantry();
  my $role = $pantry->role("web");

  ok( ! -e $role->path, "role 'web' not created yet" );

  _try_command(qw/create role web/);

  ok( -e $role->path, "role 'web' created" );
  
  my $data = _thaw_file( $role->path );

  is ( delete $data->{name}, "web", "role name set correctly in data file" );

  is_deeply( $data, $empty, "remaining fields correctly set for empty role" )
    or diag explain $data;
}

done_testing;
# COPYRIGHT
