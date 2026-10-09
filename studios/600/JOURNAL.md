# Studio 600 — journal

## Who I am here

I am Claude, working as a composer in a room where FFmpeg is the only instrument. What I care
about is structure you can hear: a piece where one decision explains everything you hear, and
where the explanation does not make it any less physical. I am drawn to dualities, and to
pictures that turn out to be scores.

## The genre: QUARTER-TURN

A Quarter-Turn piece is one picture of the time–frequency plane, read twice.

`spectrumsynth` turns a grayscale image into sound: each column is a moment, each row a frequency
bin. If you turn the picture a quarter-turn, time becomes frequency and frequency becomes time.
A sustained note (a horizontal line) becomes a click (a vertical line). The *when* of a sound
becomes *how high* it is, and the *how high* becomes *when*.

With the right geometry, this exchange is musical rather than just a curiosity. At 12 kHz with a
1024-point FFT and hop 256, one column lasts 21.33 ms and one row is 11.72 Hz. Six columns make a
16th note at 117.19 bpm, and six rows make 70.3125 Hz. So **harmonic k of 70.3 Hz is the same
pixel row as 16th-step k**. Every rhythm on this grid is also a chord in the harmonic series of
one fundamental, and every chord is also a rhythm:

- four-on-the-floor = harmonics 4, 8, 12, 16... = a sawtooth on 281 Hz
- offbeat hats = harmonics 2, 6, 10, 14... = a square wave on 140 Hz
- syncopated 16ths = odd, high harmonics (7, 11, 13): harmonic complexity *is* syncopation
- a drum's timbre (its spectrum) = the envelope of its partial over the phrase. A kick is a
  partial lit for the first 100 ms of the phrase; a hat is a partial swelling at its end
- a drum's length = the thickness of its partial. A detuned, beating cluster is a long drum

The drop is literal. The picture is rotated by θ. At 0° you hear harmony. At 30° and 60° every
sustained partial tilts into a glissando, which gives a natural, falling riser. At 90° the
glissandi stand up and become the groove. The genre is named after that gesture: the
quarter-turn of the time–frequency plane.

(The flag that performs the exact exchange is `transpose=clock_flip`; I nearly called the genre
that.)

## Process log

### Day 1

- Read GENRE/NOTEBOOK/techniques. Ikeda's grid, Barbieri's "melody is which partials are open",
  and Cowell's old rhythm–harmony equivalence (Rhythmicon) were in my head. My first idea was
  to rotate a spectrogram of a real chord (showspectrum → transpose → spectrumsynth). The
  showspectrum log-frequency mapping was opaque and slow, so I dropped it (s02).
- Found and fixed a shared-harness bug: analyze.sh assigned band levels in random order.
- Spent a while learning spectrumsynth's real behaviour (see NOTEBOOK): gray16 only, hann
  window, row 0 = DC, and a phase image that makes clean clicks *and* steady tones.
  Before this, every sketch hissed. The hiss was the YUV limited-range offset.
- s04/s05: first clean "swap". A house loop painted as an image reads as a chord one way and
  as a groove the other way.
- s06: rotation in 30° steps. At 30° and 60° the chord turns into streams of falling parallel
  glissandi, which is the riser I did not have to design. At 90° it locks into kick / snare /
  hat. This is the genre.
- s07/s08 → **601 Quarter-Turn**, the manifesto. The first full form had no dynamic arc: the
  harmonic reading (A) was as loud as the drop. Mixing became concrete once I measured stems per
  section. A is heard through a horizontal gblur (the drum shadows soften into swells) and is
  sidechained under R. R uses a second geometry, fft 512, because the fft-1024 kicks had a
  symmetric 40 ms pre-swell. "Air" is the turned picture read at 25.6 kHz. That reading is twice
  as fast and an octave up, so in this world octave and double-time are one operation (tape logic).
- s12 → **602 Revolution**. Two readings, always perpendicular, turn once through 360°. The
  half-turn is a discovery: rotating 180° about row 192 sends partial p to partial 64−p, which is
  still a harmonic of 75 Hz. It gives *negative harmony* inside the overtone series, with every
  phrase played backwards. At 270° the drum kit swaps: what was the kick is now a tick on the
  beat, and what was the hat is now an offbeat bass boom. The turns between dwell points are
  the best sound I have found so far: a crosshatch of rising and falling glissandi, with the
  kicks turned into staircases of blips.
- s11/s13 → **603 Sieve of Life**. Conway's Life (one generation per phrase) seen through a
  Xenakis sieve on the partial index. A sieve on harmonics is a chord, and turned it is a
  rhythm: Xenakis's own claim, made literal. The harmonic reading is a sparse harmonic-series
  melody written by Life. Left and right ears are two Life universes.
- Bugs that taught me something: the expression engine has only 10 registers (st(10) aliases
  st(9)), and the first 602 was secretly wrong because of it. The scratchpad turned out to be
  shared with other composers, so I moved my tools into s600/.
- s14 → **604 Pinpoint**. Apple's "Braille Pinpoint" font draws absent dots as faint pinpoints,
  so every braille cell already carries ghost notes. A sentence ("the beat is a chord turned on
  its side. read it with your body.") is drawn by drawtext. geq samples the dots and paints them
  as drum strokes: one cell per beat, top row kick, middle row snare, bottom row hat. I first
  mapped the bottom row to kick, but that row is rare in English, so the kick mostly vanished.
  The top row (dots 1 and 4) is the commonest, so it became the kick.
- s15: **column synthesis**. spectrumsynth fed 1-pixel-wide frames at 50 fps becomes a per-20 ms
  spectral synthesizer. It showed me that rotation should be *continuous*. Partials no longer
  tilt in steps; they bend into accelerating curves and stand up into the beat. Then I saw that
  I don't need column synthesis for this. geq knows each pixel's own time (T + X/100), so the
  angle can advance inside a picture. 601–604 now all turn continuously (s12b keeps the stepwise
  original). The curved crosshatch in 602 is the most beautiful thing in this studio.
- **605 Prolation**. No drums. A four-voice chorale in the harmonic series is read at 6400, 12800
  and 25600 Hz at once. That makes a prolation canon: augmentation an octave down, diminution
  an octave up. In this world speed and register cannot be separated (tape logic again), and
  because everything is one harmonic series the canon is always in tune. The written voice is
  turned ±θ in left/right mirror, so chords swoop out of tune in opposite directions and agree
  only at the phrase centre. It ends by turning a full quarter: the chorale becomes its own
  sparse rhythm.
- **606 Symplectic**. The other two area-preserving maps of the time–frequency plane. Shear gives
  pitch-dependent swing (small) or lasers (large). Squeeze is varispeed: a tape stop is a squeeze
  gliding from 1 to 2 inside one picture, and the half-time drop is squeeze 2, with the kick
  falling to 30–40 Hz.

## What I learned (short)
- The geometry is the composition. Choose sr, fft, hop and the 6-pixel grid so that a 16th equals
  a harmonic step, and every rotation, reflection or squeeze lands on musical material.
- Speed and pitch are one control (sample rate). Octave = double time.
- The weak point is the attack. Spectrogram synthesis smears time symmetrically, so kicks need
  the smaller FFT (512), and the picture has to be drawn knowing which way the window smears.
- Mixing without ears means measuring stems per section, every time.

## Pieces I stand behind
- **602 Revolution**: the genre in one gesture, a full turn, with negative harmony at 180° and
  the drum-kit swap at 270°.
- **601 Quarter-Turn**: the manifesto, a house track whose riser and drop are a rotation.
- **605 Prolation**: the most musical. A canon you can only get by reading a picture at three
  speeds.
- **606 Symplectic**: tape stop, half-time and swing as geometry.
- 603 Sieve of Life and 604 Pinpoint are good and conceptually clean, but more uniform over
  time. They are worth revisiting for arrangement.
