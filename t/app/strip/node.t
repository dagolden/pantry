use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;

subtest "remove recipe" => sub {
  my ($wd, $pantry) = _create_node or return;

  _try_command(qw(apply node foo.example.com -r nginx));
  _try_command(qw(strip node foo.example.com -r nginx));

  my $node = $pantry->node("foo.example.com");
  is_deeply( [$node->run_list], [], "strip -r nginx successful" )
    or _dump_node($node);
};

subtest "remove attribute" => sub {
  my ($wd, $pantry) = _create_node or return;

  _try_command(qw(apply node foo.example.com -d nginx.port=80));
  _try_command(qw(strip node foo.example.com -d nginx.port));

  my $node = $pantry->node("foo.example.com");
  is( $node->get_attribute('nginx.port'), undef, "attribute stripped successfully" )
    or _dump_node($node);
};

subtest "remove attribute with useless value" => sub {
  my ($wd, $pantry) = _create_node or return;

  _try_command(qw(apply node foo.example.com -d nginx.port=80));
  _try_command(qw(strip node foo.example.com -d nginx.port=8080));

  my $node = $pantry->node("foo.example.com");
  is( $node->get_attribute('nginx.port'), undef, "attribute stripped successfully" )
    or _dump_node($node);
};

subtest "strip list attribute" => sub {
  no warnings 'qw'; # separating words with commas
  my ($wd, $pantry) = _create_node or return;

  _try_command(qw(apply node foo.example.com -d nginx.port=80,8080));
  _try_command(qw(strip node foo.example.com -d nginx.port));

  my $node = $pantry->node("foo.example.com");
  is( $node->get_attribute('nginx.port'), undef, "attribute stripped successfully" )
    or _dump_node($node);
};

subtest "strip attributes with escapes" => sub {
  my ($wd, $pantry) = _create_node or return;
  _try_command(qw(apply node foo.example.com -d nginx\.port=80));
  _try_command(qw(strip node foo.example.com -d nginx\.port));

  my $node = $pantry->node("foo.example.com");
  is( $node->get_attribute('nginx\.port'), undef, "attribute stripped successfully" )
    or _dump_node($node);
};

done_testing;
# COPYRIGHT
