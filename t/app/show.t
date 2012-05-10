use v5.14;
use strict;
use warnings;
use autodie;
use Test::More 0.92;

use lib 't/lib';
use TestHelper;
use JSON;

my @cases = (
  {
    label => "node",
    type => "node",
    name => 'foo.example.com',
    new => sub { my ($p,$n) = @_; $p->node($n) },
    expected => {
      run_list => [ 'recipe[nginx]' ],
      nginx => {
        port => 80
      },
    },
  },
  {
    label => "role",
    type => "role",
    name => 'web',
    new => sub { my ($p,$n) = @_; $p->role($n) },
    expected => {
      json_class => "Chef::Role",
      chef_type => "role",
      run_list => [ 'recipe[nginx]' ],
      default_attributes => {
        nginx => {
          port => 80
        },
      },
      override_attributes => {},
    },
  },
);

for my $c ( @cases ) {
  subtest "$c->{type}: show" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});

    _try_command('create', $c->{type}, $c->{name});
    _try_command('apply', $c->{type}, $c->{name}, qw(-r nginx -d nginx.port=80));

    my $result = _try_command('show', $c->{type}, $c->{name});
    my $data = eval { decode_json( $result->output ) };

    is ( delete $data->{name}, $c->{name}, "name correct in output JSON" );

    is_deeply( $data, $c->{expected}, "remaining fields correct in output JSON" )
      or diag $result->output;
  };

  subtest "$c->{type}: show invalid" => sub {
    my ($wd, $pantry) = _create_pantry();
    my $obj = $c->{new}->($pantry, $c->{name});

    ok( ! -e $obj->path, "$c->{type} '$c->{name}' not created yet" );

    my $result = _try_command('show', $c->{type}, $c->{name}, { exit_code => "-1" });
    like( $result->error, qr/does not exist/i,
      "showing invalid $c->{type} gives error message"
    ) or diag $result->error;
  };
}

done_testing;
# COPYRIGHT
