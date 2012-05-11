use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

# establish placeholder for later localization
BEGIN { *CORE::GLOBAL::system = sub { CORE::system(@_) } }

use lib 't/lib';
use TestHelper;

my @cases = (
  {
    label => "node",
    type => "node",
    name => 'foo.example.com',
    new => sub { my ($p,$n) = @_; $p->node($n) },
  },
  {
    label => "role",
    type => "role",
    name => 'web',
    new => sub { my ($p,$n) = @_; $p->role($n) },
  },
);

for my $c ( @cases ) {
  subtest "$c->{type}: show" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});

    _try_command('create', $c->{type}, $c->{name});

    {
      my @args;
      no warnings 'redefine';
      local *CORE::GLOBAL::system = sub { @args = @_; return 0 };
      local $ENV{VISUAL} = $ENV{EDITOR} = "/bin/false";
      my $result = _try_command('edit', $c->{type}, $c->{name});
      is_deeply( \@args, ['/bin/false', $obj->path], "(fake) editor invoked" );
    }
  };
}

done_testing;
# COPYRIGHT
