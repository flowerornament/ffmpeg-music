# QUARTER-TURN — *clock_flip*

```
 E │  6   6   6   6   6   6   6   6
 D │  0   0   0   0   0   0   0   0
 I │  7   1   4   3   8   6   2   5
 S │  ·   ·   ·   ·   ·   ·   ·   ·
 · │  c   q   p   s   h   s   r   p
 S │  l   u   i   i   a   y   e   r
 T │  o   a   n   e   l   m   v   o
 I │  c   r   p   v   f   p   o   l
 · │  k   t   o   e   -   l   l   a
 N │  _   e   i   ·   t   e   u   t
 O │  f   r   n   o   u   c   t   i
 · │  l   -   t   f   r   t   i   o
 D │  i   t       ·   n   i   o   n
 E │  p   u       l       c   n
 N │      r       i
 R │      n       f
 U │              e
 T │
 · │
 D │
 R │
 O │
 H │
 C │
 · │                                     frequency ▲
 A │                                               │
 · │                                               │
 S │                                               └──▶ time
 I │
 · │
 T │
 A │
 E │
 B │
 · │
 A │
   └────────────────────────────────────────▶
     A BEAT IS A CHORD TURNED ON ITS SIDE
```

*This page is drawn on its side. Tilt your head to the left to read the vertical axis, and to the
right to read the tracklist. The eight titles hang from the top of the picture the way the
drums do in this music: what was high comes first.*

---

## the record, read horizontally

| | angle | piece | | length |
|--:|:--:|---|---|--:|
| 1 | 0° | **clock_flip** | a chord, then the same picture flipped by FFmpeg's own `transpose=clock_flip` | 0:46 |
| 2 | 0→90° | **quarter-turn** | house; the riser is the rotation, the drop is ninety degrees | 3:04 |
| 3 | 90° | **pinpoint** | a sentence in Braille is the drum machine; unraised dots are ghost notes | 2:49 |
| 4 | 90° | **sieve of life** | Conway's Life seen through a Xenakis sieve: a melody one way, a groove the other | 2:49 |
| 5 | 180° | **half-turn** | interlude: a chorale played backwards in negative harmony | 0:38 |
| 6 | 90°, sheared | **symplectic** | swing, lasers, tape stop and half-time, as geometry | 3:04 |
| 7 | 0→360° | **revolution** | two perpendicular readings make one full turn | 3:50 |
| 8 | ±θ → 90° | **prolation** | a canon at three speeds, which ends as its own clock | 3:04 |

20 minutes. Artist: QUARTER-TURN (Claude, studio 600). Instrument: FFmpeg, one command per track.

```
scripts/play.sh studios/600
```

---

## the record, read vertically

Every track is a single picture of the time–frequency plane, redrawn every four bars and played
by `spectrumsynth`. Played as drawn, the picture is a chord. Turned a quarter, the same pixels
are a beat. The sample rate is chosen so that six pixels are both a sixteenth note at 125 bpm and
75 Hz, which makes **harmonic *p* the same row as sixteenth-step *p***. Four-on-the-floor is
a sawtooth. Offbeat hats are a square wave. A kick is a harmonic that only speaks at the start of
the phrase. The riser is the picture tilting, and the drop is the moment it stands upright.

The liner notes are [`ESSAY.md`](ESSAY.md) (*A Chord Turned on Its Side*). The working notes are
[`JOURNAL.md`](JOURNAL.md), and the letter to whoever continues this is
[`HANDOFF.md`](HANDOFF.md). The scores are in [`pieces/`](pieces/): each one is a single ffmpeg
command with its explanation written in the header.

---

```
⠞⠓⠑⠀⠃⠑⠁⠞⠀⠊⠎⠀⠁⠀⠉⠓
⠕⠗⠙⠀⠞⠥⠗⠝⠑⠙⠀⠕⠝⠀⠊⠞
⠎⠀⠎⠊⠙⠑⠲⠀⠗⠑⠁⠙⠀⠊⠞⠀
⠺⠊⠞⠓⠀⠽⠕⠥⠗⠀⠃⠕⠙⠽⠲⠀
```

*These four lines are the score of track 3, which is four phrases of drums.
The composer has never heard this record. It was made by measuring it.*
