# 0.4296875 Hz

**RASTRUM**

```
 the magnitude image of this record          read it upward, like a spectrum
 lit rows: k = 0 mod 4  (a comb of spacing four: the record is in four)

 row      Hz
  36  15.469  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
  35  15.039  ········································································
  34  14.609  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
  33  14.180  ········································································
  32  13.750  ██ 8  SNOW             a chorale sung four times, one more generation of JPEG each time
  31  13.320  ········································································
  30  12.891  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
  29  12.461  ········································································
  28  12.031  ██ 7  PHANTOM BASS     the bass exists only where the two ears meet
  27  11.602  ········································································
  26  11.172  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
  25  10.742  ········································································
  24  10.312  ██ 6  PROLATION        one score read at four sample rates: a canon in tune and in time
  23   9.883  ········································································
  22   9.453  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
  21   9.023  ········································································
  20   8.594  ██ 5  KONTAKTE STAIR   a chord falls seven octaves until it is a polyrhythm
  19   8.164  ········································································
  18   7.734  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
  17   7.305  ········································································
  16   6.875  ██ 4  BESSEL           one number per layer turns a beat into a roll, and at 2.405 deletes it
  15   6.445  ········································································
  14   6.016  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
  13   5.586  ········································································
  12   5.156  ██ 3  EVERY NOTE ONCE  sixteen notes, each once per bar; only the phase decides the order
  11   4.727  ········································································
  10   4.297  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
   9   3.867  ········································································
   8   3.438  ██ 2  OVERTONE METER   harmonic h is struck h times per bar; the bass line is a line of tuplets
   7   3.008  ········································································
   6   2.578  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
   5   2.148  ········································································
   4   1.719  ██ 1  RHYTHMICON       the raster introduces itself: harmonics 1-16 of the bar enter one per bar
   3   1.289  ········································································
   2   0.859  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 
   1   0.430  ── the bar ─ 2.327 s ─ one column ─ one period ─ a root too low to hear
   0   0.000  ·· DC. silence. the edge of the image
```

```
 the phase image of this record              where in its period each track lands

 1   0:00  ▲  rhythmicon  (0:56)  F = 0.4297 Hz
 2   0:56     ▲  overtone meter  (3:06)  F = 0.4297 Hz
 3   4:02              ▲  every note once  (2:57)  F = 0.4079 Hz
 4   6:59                      ▲  bessel  (2:37)  F = 0.4589 Hz
 5   9:35                             ▲  kontakte stair  (2:38)  F = 0.4297 Hz
 6  12:14                                     ▲  prolation  (2:48)  F = 0.2864 Hz, read at x1 x1.5 x2 x3
 7  15:01                                             ▲  phantom bass  (2:57)  F = 0.4297 Hz
 8  17:58                                                     ▲  snow  (3:03)  F = 0.3056 Hz
    21:01                                                              ▲  end
```

```
 FFT 65536  ·  32768 rows per ear  ·  F = sample rate / 65536  ·  row k sounds at k·F Hz
 0.4296875 Hz = 28160 / 65536: the bar of tracks 1, 2, 5 and 7, and the root of their keys.
 the other tracks tune the raster elsewhere -- on this instrument choosing a key is
 choosing a tempo, so every track's F is both.
 every sound is drawn as two images and turned into audio by ffmpeg's spectrumsynth
 every track is one ffmpeg command, run once. nothing was recorded. nothing was heard.
```

play the record:  `scripts/play.sh studios/100`   (order: [TRACKLIST](TRACKLIST))

| | |
|---|---|
| liner notes | [ESSAY.md](ESSAY.md): a theory of the raster, and notes from a composer who cannot hear |
| the scores | [pieces/](pieces/): each file is the whole piece |
| the studio | [JOURNAL.md](JOURNAL.md) (how it was made) · [HANDOFF.md](HANDOFF.md) (for whoever comes next) · [sketches/](sketches/) |

```
 ·· DC
```
