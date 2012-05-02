use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;
use JSON;

subtest "show node" => sub {
  my ($wd, $pantry) = _create_node or return;

  _try_command(qw(apply node foo.example.com -r nginx -d nginx.port=80));
  my $result = _try_command(qw(show node foo.example.com));
  my $data = eval { decode_json( $result->output ) };
  is_deeply(
    $data,
    {
      name => 'foo.example.com',
      run_list => [ 'recipe[nginx]' ],
      nginx => {
        port => 80
      },
    },
    "output JSON correct"
  ) or diag $result->output;
};

subtest "try showing invalid node" => sub {
  my ($wd, $pantry) = _create_node or return;

  my $result = _try_command(qw(show node foo2.example.com), { exit_code => "-1" });
  like( $result->error, qr/node 'foo2\.example\.com' does not exist/i,
    "showing invalid node give error message"
  ) or diag $result->error;
};

done_testing;
# COPYRIGHT
