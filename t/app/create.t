use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

my @cases = (
  {
    label => "node",
    type => "node",
    name => 'foo.example.com',
    new => sub { my ($p,$n) = @_; $p->node($n) },
    empty => {
      run_list => [],
    },
  },
  {
    label => "node with overrides",
    type => "node",
    name => 'foo.example.com',
    opts => [qw/--host localhost --port 2222 --user vagrant/],
    new => sub { my ($p,$n) = @_; $p->node($n) },
    empty => {
      run_list => [],
      pantry_host => 'localhost',
      pantry_port => 2222,
      pantry_user => 'vagrant',
    },
  },
  {
    label => "role",
    type => "role",
    name => 'web',
    new => sub { my ($p,$n) = @_; $p->role($n) },
    empty => {
      json_class => "Chef::Role",
      chef_type => "role",
      run_list => [],
      default_attributes => {},
      override_attributes => {},
    },
  },
);

for my $c ( @cases ) {
  subtest "create $c->{label}" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});

    ok( ! -e $obj->path, "$c->{type} '$c->{name}' not created yet" );

    _try_command('create', $c->{type}, $c->{name}, @{ $c->{opts} || [] });

    ok( -e $obj->path, "$c->{type} '$c->{name}' created" );

    my $data = _thaw_file( $obj->path );

    is ( delete $data->{name}, $c->{name}, "$c->{type} name set correctly in data file" );

    is_deeply( $data, $c->{empty}, "remaining fields correctly set for empty $c->{type}" )
      or diag explain($data);
  }
}

done_testing;
# COPYRIGHT
