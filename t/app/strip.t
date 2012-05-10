use v5.14;
use strict;
use warnings;
no warnings 'qw'; # separating words with commas
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;
use JSON;

my %templates = (
  node => {
    run_list => [],
  },
  role => {
    json_class => "Chef::Role",
    chef_type => "role",
    run_list => [],
    default_attributes => {},
    override_attributes => {},
  },
);

my @cases = (
  {
    type => "node",
    name => 'foo.example.com',
    new => sub { my ($p,$n) = @_; $p->node($n) },
    subtests => [
      {
        label => "strip recipe",
        apply => [ qw/-r nginx/ ],
        strip => [ qw/-r nginx/ ],
        expected => { },
      },
      {
        label => "strip only one recipe",
        apply => [ qw/-r nginx -r postfix/ ],
        strip => [ qw/-r nginx/ ],
        expected => {
          run_list => [ qw/recipe[postfix]/ ],
        },
      },
      {
        label => "strip attribute",
        apply => [ qw/-d nginx.port=80/ ],
        strip => [ qw/-d nginx.port/ ],
        expected => { },
      },
      {
        label => "strip only one attribute",
        apply => [ qw/-d nginx.port=80 -d nginx.user=nobody/ ],
        strip => [ qw/-d nginx.user/ ],
        expected => {
          nginx => { port => 80 }
        },
      },
      {
        label => "strip entire attribute hash shoudn't work",
        apply => [ qw/-d nginx.port=80 -d nginx.user=nobody/ ],
        strip => [ qw/-d nginx/ ],
        expected => {
          nginx => {
            port => 80,
            user => 'nobody',
          },
        },
      },
      {
        label => "strip attribute with useless value",
        apply => [ qw/-d nginx.port=80/ ],
        strip => [ qw/-d nginx.port=8080/ ],
        expected => { },
      },
      {
        label => "strip attribute list",
        apply => [ qw/-d nginx.port=80,8080/ ],
        strip => [ qw/-d nginx.port/ ],
        expected => { },
      },
      {
        label => "strip escaped attribute",
        apply => [ qw/-d nginx\.port=80/ ],
        strip => [ qw/-d nginx\.port/ ],
        expected => { },
      },
    ],
  },
  {
    type => "role",
    name => 'web',
    new => sub { my ($p,$n) = @_; $p->role($n) },
    subtests => [
      {
        label => "strip recipe",
        apply => [ qw/-r nginx/ ],
        strip => [ qw/-r nginx/ ],
        expected => { },
      },
      {
        label => "strip only one recipe",
        apply => [ qw/-r nginx -r postfix/ ],
        strip => [ qw/-r nginx/ ],
        expected => {
          run_list => [ qw/recipe[postfix]/ ],
        },
      },
      {
        label => "strip default attribute",
        apply => [ qw/-d nginx.port=80/ ],
        strip => [ qw/-d nginx.port/ ],
        expected => { },
      },
      {
        label => "strip override attribute",
        apply => [ qw/--override nginx.port=80/ ],
        strip => [ qw/--override nginx.port/ ],
        expected => { },
      },
      {
        label => "strip only one attribute",
        apply => [ qw/-d nginx.port=80 -d nginx.user=nobody/ ],
        strip => [ qw/-d nginx.user/ ],
        expected => {
          default_attributes => {
            nginx => { port => 80 },
          },
        },
      },
      {
        label => "strip only one attribute default/override",
        apply => [ qw/-d nginx.port=80 --override nginx.user=nobody/ ],
        strip => [ qw/--override nginx.user/ ],
        expected => {
          default_attributes => {
            nginx => { port => 80 },
          },
        },
      },
      {
        label => "strip entire attribute hash shoudn't work",
        apply => [ qw/-d nginx.port=80 -d nginx.user=nobody/ ],
        strip => [ qw/-d nginx/ ],
        expected => {
          default_attributes => {
            nginx => {
              port => 80,
              user => 'nobody',
            },
          },
        },
      },
      {
        label => "strip attribute with useless value",
        apply => [ qw/-d nginx.port=80/ ],
        strip => [ qw/-d nginx.port=8080/ ],
        expected => { },
      },
      {
        label => "strip attribute list",
        apply => [ qw/-d nginx.port=80,8080/ ],
        strip => [ qw/-d nginx.port/ ],
        expected => { },
      },
      {
        label => "strip escaped attribute",
        apply => [ qw/-d nginx\.port=80/ ],
        strip => [ qw/-d nginx\.port/ ],
        expected => { },
      },
    ],
  },
);

for my $c ( @cases ) {
  for my $st ( @{$c->{subtests}} ) {
    subtest "$c->{type} $st->{label}" => sub {
      my ($wd, $pantry) = _create_pantry();
      my $obj = $c->{new}->($pantry, $c->{name});

      _try_command('create', $c->{type}, $c->{name});
      _try_command('apply', $c->{type}, $c->{name}, @{$st->{apply}}) ;
      _try_command('strip', $c->{type}, $c->{name}, @{$st->{strip}}) ;

      my $data = _thaw_file( $obj->path );
      $st->{expected}{name} //= $c->{name};
      for my $k ( keys %{$templates{$c->{type}}} ) {
        $st->{expected}{$k} //= $templates{$c->{type}}{$k};
      }

      is_deeply( $data, $st->{expected}, "data file correct" )
        or diag explain $data;
    };
  }
}

done_testing;
# COPYRIGHT
