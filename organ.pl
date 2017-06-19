#!/usr/local/bin/perl -w
use strict;
use warnings;
use Curses;

# This is a hacked up version of an example program from Audio::PortAudio
BEGIN {
    eval {
        require Audio::PortAudio;
    } || die "Can't find Audio::PortAudio. 
If you've build Audio::PortAudio but haven't installed it yet, use
perl -Mblib vumeter.pl [program options]
";
}
use Getopt::Long;

my $samplefrequency = 44100;
my $updatefrequency = 50;
my $help = 0;
my $verbose=0;
my $channelcount = 1;
my $api_name = "";
my $device_name = "";
my $s = GetOptions(
    "samplefrequency=i",\$samplefrequency,
    "updatefrequency=i",\$updatefrequency,
    "verbose",\$verbose,
    "channelcount=i",\$channelcount,
    "api=s",\$api_name,
    "device=s",\$device_name,
    "help",\$help
);
if (!$s || $help) {
    print "usage: $0 [options]
options:
  --samplefrequency VALUE   audio input rate. default = 22050
  --updatefrequency VALUE   display update rate. default = 40
  --channelcount    NUM     number of input channels. default = 1
  --api             NAME    API to use (ALSA, OSS ...)
  --device          NAME    input device to use
  --verbose                 be verbose
  --help                    show this message

example (default values):
   something.pl -u 40 -s 22050 -p '|' -av '#' -b ' '
";
    exit $s;
}


if ($verbose) {
    print "Available APIs: ",join(", ",map { $_->name } Audio::PortAudio::host_apis()),"\n";
}

my $api;
if ($api_name) {
    ($api) = grep { lc($_->name) eq lc($api_name) } Audio::PortAudio::host_apis();
}
else {
    $api = Audio::PortAudio::default_host_api();
}
die "No api found" unless $api;

print "Using ".$api->name."\n" if $verbose;

if ($verbose) {
    print "Available devices: ",join(", ", map { $_->name } $api->devices ),"\n";
}
my $device;
if ($device_name) {
    ($device) = grep { $_->name eq $device_name } $api->devices;
}
else {
    $device = $api->default_input_device;
}
die "No device found" unless $device;
print "Using ".$device->name."\n" if $verbose;

print "max input channels: ",$device->max_input_channels,"\n" if $verbose;

my $frames = 256;
my $stream = $device->open_write_stream( 
  { channel_count => $channelcount, sample_format => 'float32' , latency => 0.00550}, 
  $samplefrequency, $frames, 0);

$|=1;

my $buffer2 = "";
$stream->start;
use List::Util qw(min  max);
my $t=0;
my $c=0;

initscr(); 
cbreak(); noecho();

nonl();
intrflush(stdscr, 0);
keypad(stdscr, 1);
nodelay(stdscr, 1);

my @events;

my $vol = 0.3;
my $stay = 1;
while ($stay) {

  my $ch = getch();
  if($ch ne '-1') {
    if($ch eq 'v') {
      $vol -= 0.1;
      $vol = 1 if $vol < 0;
    }
    elsif($ch eq 'q') {
      $stay = 0;
    }
    elsif($ch eq 'a') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 440};
    }
    elsif($ch eq 's') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 493.88};
    }
    elsif($ch eq 'd') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 523.25};
    }
    elsif($ch eq 'f') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 587.33};
    }
    elsif($ch eq 'g') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 659.25};
    }
    elsif($ch eq 'h') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 698.46};
    }
    elsif($ch eq 'j') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 783.99};
    }
    elsif($ch eq 'k') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 880};
    }
    elsif($ch eq 'l') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 987.77};
    }
    elsif($ch eq ';') {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 1046.50};
    }
    elsif($ch eq "'") {
      push @events, { t => $t , e => ($t + 0.25*$samplefrequency), f => 1174.66};
    }
  }
  
    my @sig;
    @sig = map {0} (1..$frames*$channelcount);
    if($c == 3) {
      $c=0;
      addstring(5,  2, "vol = $vol  ");
    }
    @events =  grep {
        my $t0_ev = $_->{t};
        my $t1_ev = $_->{e};
        !($t > $t1_ev);
        } @events;
    for(@sig) {
      for my $ev (@events) {
        my $t0_ev = $ev->{t};
        my $t1_ev = $ev->{e};
        if($t >= $t0_ev and $t <= $t1_ev) {
          my $s;
          $s = sin($t/$samplefrequency * 2 * 3.141592 * $ev->{f}) * $vol;
          if($t < $t0_ev + 0.05*$samplefrequency) {
            my $v = ($t - $t0_ev)/(0.05*$samplefrequency);
            $s *= $v;
          }
          elsif($t > $t1_ev - 0.05*$samplefrequency) {
            my $v = ($t1_ev - $t)/(0.05*$samplefrequency);
            $s *= $v;
          }
          $_ += $s;
        }
      }
      $t++;
    }
    $buffer2 = pack "f".($frames * $channelcount), @sig;
    my $frames_avail = $stream->write_available;

    my $ok2 = 1;
    $ok2 = $stream->write($buffer2);
    if (!$ok2) {
      print "Buffer write overflow @ ".localtime(time)."\n";
    }
    $c++;
}


endwin();
exit;
END {
endwin();
}
