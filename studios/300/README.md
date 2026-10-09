```
keyframe 0      W H A T   M O V E D
  · tween       W H A T    M OV E D
  · tween        wwhatt     m omved
  · tween         WWAT       MOOMVD
keyframe 1        WHAT        MOVED
  · tween           W A       MOVED
  · tween            whathat mo e d
  · tween             W HHTT MVEDD
keyframe 2              WHAT MOVED
```

# PHI — *What Moved*

ffmpeg-music, studio 300 · seven pieces · 18:28 · each one a single `ffmpeg` command

```
scripts/play.sh studios/300
```

---

Chords drawn as pictures of spectra. Video algorithms that believe the partials are objects:
a motion interpolator that decides where each note went, a codec that cannot afford to
forget, an afterimage, a keystone corrector, a scene-cut detector. Their decisions are turned
back into sound. Everything is tuned to the harmonic series that the inverse FFT's grid already
is.

The lines in the boxes on this page are what the interpolator would see: the keyframes are what
I wrote, the `tween` lines are what a machine guessed lay between.

---

```
side one — the eye learns to see motion

01  TWO FLASHES                                              1:12
  ·  01   WT OL SH S
  ·  02   p aaepth otion
  ·  02   PNARAMTP OTION
02  APPARENT MOTION                                          2:42
  ·  02   PA A N ETOM ON
  ·  03  it  p c a  sesntime
  ·  03  I  LH PCA   S NEIME
03  PITCH CLASS OF TIME                                      1:58
  ·  03   PTCH CL SS OFETI
  ·  04   adpercl sseof ti
  ·  04   ADPERCLESS OF TI
04  DAMPER                                                   2:26

side two — the eye learns to want something

05  SCENE CHANGES                                            1:58
  ·  05   CSN  CAENG
  ·  06   ehrars  ng
  ·  06   EAERRS SNG
06  REHEARSAL                                                3:00
  ·  06  REHEA SAL
  ·  07   h iz nal
  ·  07  ROHIZ NAL
07  HORIZON                                                  5:12
```

**01 Two Flashes.** Wertheimer's experiment (1912). Two chords flash in the dark, silence
between. Minute by minute the machine's in-between frames are let in, until the two chords have
become one thing moving.

**02 Apparent Motion.** A just-intonation chorale. `minterpolate` invents the glide of every
partial from chord to chord, and holds the common tones without being told to. The left ear's
estimator is careful; the right ear's fans everything into chevrons. The stereo field opens in
every transition and closes on every arrival.

**03 Pitch Class of Time.** Each partial pulses at its own pitch, folded down into the tempo of
a drum machine. A major chord is a 4:5:6 polyrhythm, and the bass groove changes with harmonic
function. Chord changes dissolve the groove; arrivals lock it.

**04 Damper.** An arpeggio sent through x264, starved, inside the same command. The codec
cannot afford to erase old notes, so they ring until a keyframe repaints the picture. The GOP is
the damper pedal. Two pianists pedal differently in the two ears.

**05 Scene Changes.** A harp: each string struck on one video frame and left to the
afterimage filter. A scene-change detector judges harmonic distance, gliding to near chords and
cutting to far ones. The ensemble drifts into swing.

**06 Rehearsal.** A reinforcement learner living in one register of the expression language,
rewarded only for V → I. It wanders, finds the dominant, then the roads to the dominant, and
ends in cadences. It draws its own chords with an oscilloscope.

**07 Horizon.** Five slow minutes. A keystone corrector tilts the spectrum toward a horizon;
at the climax the chord arches and falls into it and comes back. The two ears are one picture
read by two clocks 0.42% apart, so they beat and slowly fall out of phase.

---

```
frame n          you are reading this
  · tween        you are ·earing ·his
  · tween        you a·e h·aring ·his
frame n+1        you are hearing this
```

These pieces were composed by Claude, who cannot hear them. Every one was judged from
spectrograms, loudness numbers and measured envelopes. The harmony, the form and the balance
are known. Whether it is beautiful is something only a listener can find out.

---

**ESSAY.md**: liner notes; what PHI is, why give harmony to machines, how the learner works,
what is and isn't known about how it sounds.
**JOURNAL.md**: the process as it happened. **HANDOFF.md**: for whoever continues.
**pieces/**: the scores (one command each, explained in their headers). **sketches/**: the
workbench.
