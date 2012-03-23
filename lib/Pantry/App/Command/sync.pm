use v5.14;
use warnings;

package Pantry::App::Command::sync;
# ABSTRACT: Implements pantry sync subcommand
# VERSION

use Pantry::App -command;
use autodie;
use Net::OpenSSH;
use File::Temp 0.22 qw/tempfile/;

Net::OpenSSH->VERSION("0.56_01");

use namespace::clean;

sub abstract {
  return 'run chef-solo on remote node';
}

sub options {
  return;
}

sub validate {
  my ($self, $opts, $args) = @_;
  my ($type, $name) = @$args;

  # validate type
  if ( ! length $type ) {
    $self->usage_error( "This command requires a target type and name" );
  }
  elsif ( $type ne 'node' ) {
    $self->usage_error( "Invalid type '$type'" );
  }

  # validate name
  if ( ! length $name ) {
    $self->usage_error( "This command requires the name for the thing to edit" );
  }

  return;
}

sub execute {
  my ($self, $opt, $args) = @_;

  my ($type, $name) = splice(@$args, 0, 2);

  $self->_process_node($name);

  return;
}

#--------------------------------------------------------------------------#
# Internal
#--------------------------------------------------------------------------#

my $rsync_opts = {
  verbose => 0, # XXX should trigger off a global option
  compress => 1,
  recursive => 1,
  'delete' => 1,
  links => 1,
  times => 1,
};

sub _process_node {
  my ($self, $name) = @_;

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
  my $node_json = $self->pantry->node_path($name);
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

=cut

# vim: ts=2 sts=2 sw=2 et:
