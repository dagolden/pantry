use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

subtest "apply" => sub {
  my $result = _try_command(qw(help apply));
  my $expected = qr/The apply command/;
  like( $result->output, $expected, "saw help text" );
};

done_testing;
# COPYRIGHT
