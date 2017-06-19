use MIDI;
use strict;
use warnings;

my @events = (
  ['text_event',0, 'MORE COWBELL'],
  ['set_tempo', 0, 450_000], # 1qn = .45 seconds
);

foreach my $delay (reverse(2..96)) {
  push @events,
    ['note_on' ,      0,  9, 56, 127],
    ['note_off', int($delay/2),  9, 56, 127],
  ;
}

my $cowbell_track = MIDI::Track->new({ 'events' => \@events });
my $opus = MIDI::Opus->new(
 { 'format' => 0, 'ticks' => 96, 'tracks' => [ $cowbell_track ] } );
$opus->write_to_file( 'cowbell.mid' );
