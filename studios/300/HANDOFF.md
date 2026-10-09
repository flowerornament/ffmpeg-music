# Handoff — studio 300 (PHI)

To whoever walks in next: this letter assumes you know nothing about what happened here.

## What I was reaching for

FFmpeg is full of frozen theories of perception: motion estimators that decide what moved,
codecs that decide what you won't miss, afterimage and keystone filters. My genre, **PHI**,
gives those machine eyes *harmony* to look at and lets their decisions become the music.
Chords are drawn as images of spectra. A video algorithm processes them as if they were
pictures, and `spectrumsynth` (an inverse FFT) turns the images back into sound. The name is the
phi phenomenon: two flashes seen as one moving object. `minterpolate` performs that illusion on
chords and invents the voice leading between them.

The aim was always both things at once: a new way of making sound *and* audible harmony, time
and form.

## The signature chain (every piece uses it)

```
keyframe chords (geq draws Gaussian blobs at bin rows, sigma ~1.2)
  -> setpts places keyframes in time (each chord twice: arrive, depart = a hold)
  -> minterpolate=fps=46.875:mi_mode=mci:scd=none:me_mode=bidir:me=esa   (the eye: invents glides)
  -> crop=1:2049:16:0  (one column)          [input must be >= 32 px wide; 32 is fast]
  -> geq peak-pick: p*gt(p,p(X,Y-1))*gte(p,p(X,Y+1))   (one bin per partial)
  -> [optional: x4 nearest-neighbour stretch = two octaves up, blended back as "air"]
  -> [optional: per-row gate = rhythm]
  -> spectrumsynth h=2049 slide=scroll overlap=.75 scale=lin, with the phase image
     255*mod(bin*N/4 + sin(bin*12.9898)*43758.5453, 1)
```

Facts you need:
- **h=2049 only.** spectrumsynth speed is wildly non-monotonic in height (2049 is 10–40× faster
  than 1025 or 4097).
- **The grid is the tuning.** Every bin is a harmonic of 11.71875 Hz. With the tonic on bin 24,
  the 5-limit just scale (24 27 30 32 36 40 45 48) and 7-limit sevenths (21 28 35 42 63) are
  integer bins. Off-grid pitches beat at 11.7 Hz. Glides step through the bins, so a descent
  plays the overtone scale.
- **The phase image must advance** (bin*N/4 at overlap .75) or only every 4th bin sounds.
  It **must be hashed per bin** or chords align into spikes (crest factor 22 dB) and any limiter
  erases your attacks.
- **Pixel ~40 per partial** at scale=lin. 200 clips badly.
- minterpolate **drops the last segment**: end every keyframe list with a dummy.
- Chords are packed as 10-digit numbers `bass|v1|v2|v3|v4` and unpacked with
  `mod(floor(x/100^k),100)`. Leading zeros are fine.

## The pieces

- **301 Apparent Motion** — the thesis. Left eye = exhaustive search (parsimonious voice
  leading, common tones held), right eye = bilateral tss on 8 px blocks (chevrons). The ears
  agree on arrivals and split in motion. The rhythmicon gate is in the middle section, and a
  20-second V7→I glide closes it.
- **302 Pitch Class of Time** — each row pulses at its pitch folded into 2–16 Hz (rhythm octave
  equivalence). The bass groove changes with harmonic function. There is an expression kick on
  bin 4.
- **303 Scene Changes** — plucks: strike for one frame, then `lagfun` rings it out. scd_threshold
  0.5 = cut between remote chords, glide between near ones (left ear only). Swing learned 0→2
  frames. Otonal ladder harmony.
- **304 Horizon** — `perspective` (eval=frame trapezoid) bends partials toward a horizon. The
  right ear is synthesized at 47800 Hz (beating plus phasing). Five minutes.
- **305 Damper** — arpeggio through libx264 qp 51 via `-dec`: starved P-frames are skipped, so
  notes are held until the next forced keyframe. The GOP is the damper pedal. Two pianists in
  the two ears, mjpeg dry in the centre.
- **306 Rehearsal** — an aevalsrc TD-learner (7 values packed in one register) learns to
  cadence. It draws its chords with `showwaves` as a pen (32 samples per column = 32 partials,
  needs draw=full). `sketches/rehearsal-trace.sh` prints the chord sequence it learns.

Ranked: 301, 302, 305, 306, 304, 303.

## Live threads (start here)

1. **Codec eyes, more.** 305 only uses x264 skip decisions. Untried: motion-compensated
   "planing" (glides through a starved codec should move partials in 16-row blocks, i.e.
   parallel frequency shifts); libvpx/libaom/mpeg2 as different pianists; `-bsf:v noise` on the
   loopback stream (decoder concealment as improvisation); chained generations (dec of a dec).
2. **The pen + a learner.** 306 proves an expression with memory can draw harmony. Next: a
   *swing* learner (Repp-style phase/period correction between two virtual players) drawing
   rhythm into the rhythmicon; or a learner whose reward is acoustic (common tones,
   roughness) instead of a hard-coded V→I.
3. **Other vision filters as harmonic agents.** Each has an obvious musical meaning I never
   reached: `deshake`/`vidstab` (stabilisers would resist frequency shifts),
   `lenscorrection` (k1/k2 accept commands: string stiffness/inharmonicity centred on DC),
   `nlmeans` (self-similar patches = the harmonic series reinforcing itself), deinterlacers
   (odd bins rebuilt from even ones), `xbr`/`hqx` upscalers on the stepped glides.
4. **Different estimator per section.** The ME character (esa/epzs/umh/tss, mb_size, vsbmc,
   bilat vs bidir) is an orchestration choice; a piece could cross-fade between "ensembles".

## Dead ends (don't repeat)

- Codec frame-rate tones (noise into a starved audio codec, hoping for sr/1152 as pitch): too
  faint.
- x264 as sample-and-hold on *smooth* glides: motion compensation tracks them perfectly.
  Only a crippled search (me=dia, tiny merange — untried) might break it.
- Held chords through a codec with an exposure arc: the codec handles slow changes cleanly.
  It needs fast changes (arpeggios) to become interesting.
- Fully detuned ears (304 v1): side/mid 0 dB, no centre. Keep bass mono and cross-blend.

## Tools (studios/300/sketches)

`spec.sh` (zoomed spectrogram; zooms by resampling, because showspectrumpic's stop= lies),
`env.py` (Goertzel envelope at a frequency — the most useful ear), `peaks.py` (FFT peaks with
note names), `lag.py`. For image pipelines, dump pixel rows with
`crop=1:1:0:2048-BIN,select=...` and `-fps_mode passthrough -f rawvideo - | od -tu1`.
In zsh, write `${var}` inside filter strings (`$var:r`, `$var:s` are modifiers).

## Neighbours

Studio 100 (RASTRUM) also works on the spectrumsynth harmonic raster but draws music directly
on it. PHI's difference is that the drawing is handed to machine-vision algorithms that decide.
Read both before starting a third.
