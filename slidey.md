class: center, middle
# Playing with Music with Perl

### Brian Gottreu
???
my name's Brian Gottreu and this is playing WITH music with perl

though it's possible to create audio directly with perl, in real-ish time (demo)
that's not the focus

here's a sonic taste
play jump.mid

---
name: erg
layout: true
class: middle, erg
---
#MIDI
???
this talk will focus on creating midi files and letting someone else
worry about rendering it

w're using fluidsynth which uses soundfonts

but you could also use timidity or wildmidi

or csound, chuck, puredata

or comeerical programs like reason
---
```perl
use strict;
use warnings;
use MIDI;

my @events = (
  ['text_event',0, 'MORE COWBELL'],
  ['set_tempo', 0, 450_000], # 1qn = .45 seconds
);

foreach my $delay (reverse(2..96)) {
  push @events,
    ['note_on' ,             0,  9, 56, 127],
    ['note_off', int($delay/2),  9, 56, 127],
  ;
}

my $cowbell_track = MIDI::Track->new({ 'events' => \@events });
my $opus = MIDI::Opus->new(
 { 'format' => 0, 'ticks' => 96, 'tracks' => [ $cowbell_track ] } );
$opus->write_to_file( 'cowbell.mid' );
```
???
tempo is in MICRO seconds

note on and note off seperate

note, time, channel, pitch, velocity

time is a delta time, the time since the last event

which is not how i think and also creates a dependence on early events

ptich is midi note value 0 to 127

60 is middle c

instead we can use midi:score
---
# MIDI::Score
???
a list of lists
---
```perl
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
my $opus = MIDI::Opus->new({'tracks' => [ $track ]});
$opus->write_to_file( 'midi-score.mid' );
```
???
it's still a list of lists, but now instead of a delta time and seperate note on and note off events

there is a single not event that has an absolute time and a duration

makes it much easier to time shift events
---
# Music::Tempo

```perl
bpm_to_ms($bpm)

bpm_to_italian($bpm)
italian_to_bpm($marking)
ms_to_bpm($ms,$beat)
```
???
allegro adante, etc

optional second argument to specify beat other than quarter note
---
# Music::Chord::Note

```perl
use Music::Chord::Note;

my $cn = Music::Chord::Note->new();

my @tone = $cn->chord('CM7');
print "@tone"; # C E G B

my @tone_num = $cn->chord_num('M7');
print "@tone_num"; # 0 4 7 11

```
???
get a list of note names

or a list of semiton offsets, which i prefer because transposition is arithmetic
---
# Music::Chord::Note
```perl
my $cn = Music::Chord::Note->new();
my $start = 0;
for my $chord (qw(base m dim aug 7 m7 9 -9#5 M11 m11 13)) {
  for my $note ($cn->chord_num($chord)) {
    push @score, ['note', $start, 96*2, 0, 60 + $note, 90];
  }
  $start += 96*2;
}
```
???
base means major triad

jazzy
---
# Music::Chord::Namer
```perl
use Music::Chord::Namer qw/chordname/;

print chordname(qw/C E G/); # prints C
print chordname(qw/C Eb G Bb D/); # prints Cm9
print chordname(qw/G C Eb Bb D/); # prints Cm9/G
```
???
inverse, give it notes, get chord back

doesn't work with semitone offsets

(well volunteered)
---
# Music::Scales
```perl
use Music::Scales;

my @maj = get_scale_notes('Eb');           # defaults to major
print join(" ",@maj);                      # "Eb F G Ab Bb C D"
my @blues = get_scale_nums('blues');          
print join(" ",@blues);                    # "0 3 5 6 7 10"
```
???
like music::chord::note you cqn get names or semitone offsets
---
```
  1 ionian / major / hypolydian
  2 dorian / hypmixolydian
  3 phrygian / hypoaeolian
  4 lydian  / hypolocrian
  5 mixolydian / hypoionian
  6 aeolian / hypodorian / minor / m
  7 locrian / hypophrygian
  8 harmonic minor / hm
  9 melodic minor / mm
 10 blues 
 11 pentatonic (pmajor)
 12 chromatic 
 13 diminished 
 14 wholetone 
 15 augmented 
 16 hungarian minor 
 17 3 semitone 
 18 4 semitone 
 19 neapolitan minor (nmin)
 20 neapolitan major (nmaj)
 21 todi 
 22 marva 
 23 persian 
 24 oriental 
 25 romanian 
 26 pelog 
 27 iwato 
 28 hirajoshi 
 29 egyptian 
 30 pentatonic minor (pminor)

```
---
# Music::Scales

```perl
my $start = 0;
for my $scale (1..7,12,14,17,18) {
  for my $note (get_scale_nums($scale)) {
    push @score, ['note', $start, 96/2, 0, 60 + $note, 90];
    $start += 96/2;
  }
  $start += 96/2;
}
```
???
when the scales stop being 7 notes in legnth, it gets less musical
---
# Music::Chord::Positions
---
# Music::Chord::Positions
```
C E G
E G C
G C E
```
---
# Music::Chord::Positions
```perl
my $inv = Music::Chord::Positions->new;
my $start = 0;
for my $chord (@{$inv->chord_inv([ Music::Chord::Note->new->chord_num('13') ])}) {
  for my $note (@{$chord}) {
    push @score, ['note', $start, 96*2, 0, 40 + $note, 90];
  }
  $start += 96*2;
}

```
---
# Music::Tension::PlompLevelt
# Music::Tension::Cope
???
Plomp-Levelt consonance curve calculations based on work by William Sethares and others ("SEE ALSO" for links). None of this will make sense without some grounding in music theory and the referenced papers.

Cope -
tension analysis for equal temperament music
using the method outlined by David Cope in the text "Computer Models of Musical Creativity"
---
# Music::Tension::PlompLevelt
# Music::Tension::Cope
```perl
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
```
---
```perl
my $section1 = <<End;
#.2.3.4.5.6.7.8.
x     x     x



 x   x x   x x


  x x   x x   x




   x     x     x
End

my $drum1 = <<End;
#.2.3.4.5.6.7.8.
x x    xx x

    x       x



x x x x x x x x
End

for my $i (0..127) {
  push @score, map { $_->[1] += 96*8*$i; $_ } section_to_score($section1, 16, 50, $i, 2);
  push @score, map { $_->[1] += 96*8*$i; $_ } section_to_score($drum1, 16, 36, 0, 9);
}
```
???
i definietely think of drum patters like this

it's piano roll like
---
# Other modules

+ MIDI::Pitch
+ Music::AtonalUtil
+ Music::Canon
+ Music::Gestalt
+ Music::Harmonics
+ Music::Interval::Barycentric
+ Music::Intervals
+ Music::LilyPondUtil
+ Music::Note
+ Music::Note::Frequency
+ Music::Note::Role::Operators
+ Music::PitchNum
+ Music::Scala
+ Music::VoiceGen
???
---
# Thanks
