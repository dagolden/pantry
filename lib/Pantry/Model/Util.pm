use v5.14;
use warnings;

package Pantry::Model::Util;
# ABSTRACT: Pantry data model utility subroutines
# VERSION

use Exporter qw/import/;
our @EXPORT_OK = qw/dot_to_hash hash_to_dot/;

sub dot_to_hash {
  my ($hash, $key, $value) = @_;

  my ($top_key, $rest) = split qr{(?<!\\)\.}, $key, 2;
  if ( $rest ) {
    my $new_hash = $hash->{$top_key} || {};
    dot_to_hash($new_hash, $rest, $value);
    $hash->{$top_key} = $new_hash;
  }
  else {
    # un-escape '\.'
    $key =~ s{\\\.}{.}g;
    $hash->{$key} = $value;
    return;
  }
}

sub hash_to_dot {
  my ($key, $value) = @_;
  if ( ref $value eq 'HASH' ) {
    my @pairs;
    for my $k ( keys %$value ) {
      my $v = $value->{$k};
      $k =~ s{\.}{\\.}g; # escape existing dots in key
      for my $item ( hash_to_dot($k, $v) ) {
        $item->[0] = "$key\.$item->[0]";
        push @pairs, $item;
      }
    }
    return @pairs;
  }
  else {
    return [$key, $value];
  }
}

1;

