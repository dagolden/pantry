use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.96;

use lib 't/privlib';
use App::Cmd::Tester;
use Pantry::App;
use JSON;

my @cases = (
  {
    cli => [qw(--recipe arecipe)],
    args => [],
    opts => { recipe => [ 'arecipe' ] },
  },
  {
    cli => [qw(-r arecipe)],
    args => [],
    opts => { recipe => [ 'arecipe' ] },
  },
  {
    cli => [qw(-r arecipe -r brecipe)],
    args => [],
    opts => { recipe => [ 'arecipe', 'brecipe' ] },
  },
  {
    cli => [qw(--default nginx.port=80)],
    args => [],
    opts => { default => [ 'nginx.port=80' ] },
  },
  {
    cli => [qw(-d nginx.port=80)],
    args => [],
    opts => { default => [ 'nginx.port=80' ] },
  },
  {
    cli => [qw(-d nginx.port)],
    args => [],
    opts => { default => [ 'nginx.port' ] },
  },
  {
    cli => [qw(-d nginx.port=80 -d nginx.user=nobody)],
    args => [],
    opts => { default => [ 'nginx.port=80', 'nginx.user=nobody' ] },
  },
);

for my $case ( @cases ) {
  my @cli = @{$case->{cli}};
  my $label = join(" ", @cli);
  my $exp = {
    args => $case->{args},
    opts => $case->{opts},
  };

  my $r = test_app( 'Pantry::App' => [ 'clidump', @cli ] );

  if ( $r->error ) {
    fail ( "Error: $label" ) or diag explain $r;
  }
  else {
    my $got = eval { decode_json( $r->stdout ) };
    if ( $got ) {
      is_deeply( $got, $exp , "Check: $label" )
        or diag join("\n", "GOT:", explain($got), "\nEXPECTED:", explain($exp) );
    }
    else {
      my $err = $@;
      fail "Error: $label" or diag $err;
    }
  }
}

done_testing;
# COPYRIGHT
