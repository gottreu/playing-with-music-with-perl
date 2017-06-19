use strict;
use warnings;
use MIDI;
use Music::Tempo;

my @score = (
 ['set_tempo', 0, bpm_to_ms(120) * 1000],
 ['patch_change', 0, 1, 14],
 ['note', 0, 96, 1, 55, 96],
 ['note', 96, 96, 1, 59, 96],
 ['note', 192, 96, 1, 57, 96],
 ['note', 288, 192, 1, 50, 96],
 ['note', 480, 96, 1, 55, 96],
 ['note', 576, 96, 1, 57, 96],
 ['note', 672, 96, 1, 59, 96],
 ['note', 768, 192, 1, 55, 96],
 ['note', 960, 96, 1, 59, 96],
 ['note', 1056, 96, 1, 55, 96],
 ['note', 1152, 96, 1, 57, 96],
 ['note', 1248, 192, 1, 50, 96],
 ['note', 1440, 96, 1, 50, 96],
 ['note', 1536, 96, 1, 57, 96],
 ['note', 1632, 96, 1, 59, 96],
 ['note', 1728, 192, 1, 55, 96]
);

my $events = MIDI::Score::score_r_to_events_r(\@score);
my $track = MIDI::Track->new;
$track->events_r($events);
my $opus = MIDI::Opus->new(
 { 'format' => 0, 'ticks' => 96, 'tracks' => [ $track ] } );
$opus->write_to_file( 'midi-score.mid' );
