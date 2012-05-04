use v5.14;
use warnings;

package Pantry::App::Command::sync;
# ABSTRACT: Implements pantry sync subcommand
# VERSION

use Pantry::App -command;
use autodie;
use Net::OpenSSH;
use Path::Class;
use File::Temp 0.22 qw/tempfile/;

Net::OpenSSH->VERSION("0.56_01");

use namespace::clean;

sub abstract {
  return 'Run chef-solo on remote node';
}

sub command_type {
  return 'TARGET';
}

sub valid_types {
  return qw/node/
}

my $rsync_opts = {
  verbose => 0, # XXX should trigger off a global option
  compress => 1,
  recursive => 1,
  'delete' => 1,
  links => 1,
  times => 1,
};

sub _sync_node {
  my ($self, $opt, $name) = @_;

  say "Synchronizing $name";

  # open SSH connection
  my $ssh = Net::OpenSSH->new($name, user => 'root');
#  $Net::OpenSSH::debug = 255;
  die "Couldn't establish an SSH connection: " . $ssh->error . "\n"
    if $ssh->error;

  # ensure destination directories
  for my $d ( qw( /etc/chef /var/chef-solo ) ) {
    $ssh->system("mkdir -p $d")
      or die "Could not create $d\n";
  }

  # generate local solo.rb and rsync it to /etc/chef/solo.rb
  my ($fh, $solo_rb) = tempfile( "pantry-solo.rb-XXXXXX", TMPDIR => 1 );
  print {$fh} $self->_solo_rb_guts;
  close $fh;
  $ssh->rsync_put($rsync_opts, $solo_rb, "/etc/chef/solo.rb")
    or die "Could not rsync solo.rb\n";

  # rsync node JSON to remote /etc/chef/node.json
  # XXX should really check to be sure it exists
  my $node_json = $self->pantry->node($name)->path->stringify;
  $ssh->rsync_put($rsync_opts, $node_json, "/etc/chef/node.json")
    or die "Could not rsync node.json\n";

  # rsync cookbooks to remote /var/chef-solo/cookbooks
  $ssh->rsync_put($rsync_opts, "cookbooks", "/var/chef-solo")
    or die "Could not rsync cookbooks\n";

  # ssh execute chef-solo
  my $command = "chef-solo";
  $command .= " -l debug" if $ENV{PANTRY_CHEF_DEBUG};
  $ssh->system($command) # XXX eventually capture output
    or die "Error running chef-solo\n";

  # scp get run report
  # NOT IMPLEMENTED YET
  my $report = $ssh->capture("ls -t /var/chef-solo/reports | head -1");
  chomp $report;
  # XXX should check that the report timestamp makes sense -- xdg, 2012-05-03

  dir("reports")->mkpath;
  $ssh->rsync_get($rsync_opts, "/var/chef-solo/reports/$report", "reports/$name");

}

sub _solo_rb_guts {
  return << 'HERE';
file_cache_path "/var/chef-solo"
cookbook_path "/var/chef-solo/cookbooks"
json_attribs "/etc/chef/node.json"
require 'chef/handler/json_file'
report_handlers << Chef::Handler::JsonFile.new(:path => "/var/chef-solo/reports")
exception_handlers << Chef::Handler::JsonFile.new(:path => "/var/chef-solo/reports")
HERE
}

1;

=for Pod::Coverage options validate

=head1 SYNOPSIS

  $ pantry sync node foo.example.com

=head1 DESCRIPTION

This class implements the C<pantry sync> command, which is used to rsync recipes
and node data to a server and then run C<chef-solo> on the server to finish configuration.

=cut

# vim: ts=2 sts=2 sw=2 et:
