#!/usr/bin/env perl

use strict;
use warnings;
use MIDI;
use Music::Tempo;
use Music::Scales;
 
my $opus = MIDI::Opus->new();
my @score = (
['set_tempo', 0, bpm_to_ms(145) * 1000],
['patch_change', 0, 0, 65],
);

my $start = 0;
for my $scale (1..7,12,14,17,18) {
  for my $note (get_scale_nums($scale)) {
    push @score, ['note', $start, 96/2, 0, 60 + $note, 90];
    $start += 96/2;
  }
  $start += 96/2;
}

my $events = MIDI::Score::score_r_to_events_r(\@score);
my $track = MIDI::Track->new;
$track->events_r($events);

$opus->tracks($track);
$opus->write_to_file('music-scales.mid');
