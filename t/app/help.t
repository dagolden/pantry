use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

my @commands = qw(
  apply
);
#  edit
#  init
#  list
#  show
#  strip
#  sync

for my $c ( @commands ) {
  subtest "help $c" => sub {
    my $result = _try_command("help", $c);
    my $expected = qr/The '$c' command/;
    like( $result->output, $expected, "saw help text" );
  };
  subtest "$c --help" => sub {
    my $result = _try_command($c, "--help");
    my $expected = qr/The '$c' command/;
    like( $result->output, $expected, "saw help text" );
  };
}

done_testing;
# COPYRIGHT
