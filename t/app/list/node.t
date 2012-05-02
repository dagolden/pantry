use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;
use JSON;

subtest "list node" => sub {
  my ($wd, $pantry) = _create_node or return;

  _try_command(qw(create node foo2.example.com));
  my $result = _try_command(qw(list node));
  my $err;
  like( $result->output, qr/^foo\.example\.com$/ms,
    "saw first node in output" 
  ) or $err++;
  like( $result->output, qr/^foo2\.example\.com$/ms,
    "saw second node in output" 
  ) or $err++;
  diag "OUTPUT:\n" . $result->output if $err;
};

done_testing;
# COPYRIGHT
