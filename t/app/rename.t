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
  },
#  {
#    label => "role",
#    type => "role",
#    name => 'web',
#    new => sub { my ($p,$n) = @_; $p->role($n) },
#  },
);

local $ENV{PERL_MM_USE_DEFAULT} = 1;

for my $c ( @cases ) {
  subtest "$c->{label}: rename" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});
    my $new = $c->{new}->($pantry, "renamed");
    _try_command('create', $c->{type}, $c->{name});
    _try_command('rename', $c->{type}, $c->{name}, "renamed");
    ok( ! -e $obj->path, "original object is gone" );
    ok( -e $new->path, "renamed object exists" );
  };

  subtest "$c->{label}: rename missing" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});
    my $new = $c->{new}->($pantry, "renamed");
    my $result = _try_command('rename', $c->{type}, $c->{name}, "renamed", { exit_code => -1});
    like( $result->error, qr/doesn't exist/, "error message" );
    ok( ! -e $obj->path, "original object not there" );
    ok( ! -e $new->path, "renamed object not there" );
  };

  subtest "$c->{label}: rename won't clobber" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});
    my $new = $c->{new}->($pantry, "renamed");
    _try_command('create', $c->{type}, $c->{name});
    _try_command('create', $c->{type}, "renamed");
    my $result = _try_command('rename', $c->{type}, $c->{name}, "renamed", { exit_code => -1});
    like( $result->error, qr/already exists/, "error message" );
    ok( -e $obj->path, "original object is there" );
    ok( -e $new->path, "existing object is there" );
  };
}



done_testing;
# COPYRIGHT
