use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

my @cases = (
  {
    label => "nodes",
    type => "node",
    names => ['foo.example.com', 'bar.example.com'],
    new => sub { my ($p,$n) = @_; $p->node($n) },
  },
  {
    label => "nodes in specified environment",
    type => "node",
    args => [qw/-E test/],
    names => ['foo.example.com', 'bar.example.com'],
    new => sub { my ($p,$n) = @_; $p->node($n, {env => 'test'}) },
  },
  {
    label => "roles",
    type => "role",
    names => ['web', 'db'],
    new => sub { my ($p,$n) = @_; $p->role($n) },
  },
  {
    label => "environments",
    type => "environment",
    names => ['test', 'prod'],
    new => sub { my ($p,$n) = @_; $p->environment($n) },
  },
);

for my $c ( @cases ) {
  subtest "list $c->{label}" => sub {
    my ($wd, $pantry) = _create_pantry();
    my @args = @{$c->{args} || []};

    for my $name ( @{$c->{names}} ) {
      _try_command('create', $c->{type}, $name, @args);
    }

    my $result = _try_command('list', $c->{type}, @args);

    my $err;
    for my $name ( @{$c->{names}} ) {
      like( $result->output, qr/^\Q$name\E$/ms,
        "saw '$name' in output" 
      ) or $err++;
    }
    diag "OUTPUT:\n" . $result->output if $err;
  };
}

done_testing;
# COPYRIGHT
