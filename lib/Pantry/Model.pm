use v5.14;
use warnings;

package Pantry::Model;
# ABSTRACT: Pantry data model class framework
# VERSION

1;

=head1 DESCRIPTION

The C<Pantry::Model::*> classes provide a data model and API for managing files
in a 'pantry' directory.  These classes describe in abstract terms the
information needed to manage servers with the
L<chef-solo|http://wiki.opscode.com/display/chef/Chef+Solo> configuration management
tool.

The classes include:

=for :list
* L<Pantry::Model::Pantry> -- models the 'pantry' directory and its contents
* L<Pantry::Model::Node> -- models configuration data for a 'node', including a
C<run_list> of recipes/roles and associated configuration attributes

=cut

