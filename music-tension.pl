#!/usr/bin/env perl

use strict;
use warnings;
use Music::Chord::Note;
use Music::Tension::PlompLevelt;
use Music::Tension::Cope;
 
my $tension_p = Music::Tension::PlompLevelt->new;
my $tension_c = Music::Tension::Cope->new;
my $cn = Music::Chord::Note->new();
my $start = 0;
for my $chord (qw(base m dim aug 7 m7 9 -9#5 M11 m11 13)) {
  my @n = $cn->chord_num($chord);
  my $tp = $tension_p->vertical([@n]);
  my $tc = $tension_c->vertical([@n]);
  print "$chord\t$tp\t$tc\n";
}
