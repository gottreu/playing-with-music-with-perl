#!/usr/bin/env perl

use strict;
use warnings;
use MIDI;
use Music::Tempo;
use Music::Chord::Note;
 
my $opus = MIDI::Opus->new();
my @score = (
['set_tempo', 0, bpm_to_ms(125) * 1000],
['patch_change', 0, 0, 16],
);

my $cn = Music::Chord::Note->new();
my $start = 0;
for my $chord (qw(base m dim aug 7 m7 9 -9#5 M11 m11 13)) {
  for my $note ($cn->chord_num($chord)) {
    push @score, ['note', $start, 96*2, 0, 60 + $note, 90];
  }
  $start += 96*2;
}

my $events = MIDI::Score::score_r_to_events_r(\@score);
my $track = MIDI::Track->new;
$track->events_r($events);

$opus->tracks($track);
$opus->write_to_file('music-chord-note.mid');
