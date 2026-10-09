# Compositional techniques of experimental electronic / computer musicians

Scope: concrete, implementable techniques, not biography. Each technique is a bullet
ending in a **DSP recipe** one-liner, written so it can be built from ffmpeg primitives
(`sine`, `aevalsrc`, `anoisesrc`, `afir`, `afftfilt`, `aecho`, `asetrate`, `aresample`,
`acrusher`, `adelay`, `amix`, `amerge`, `aloop`, `atrim`, `concat`, `volume` expressions,
`tremolo`, `vibrato`, `aphaser`, `bandpass`, `lowpass`, `equalizer`, `rubberband`, `atempo`).

Notation: `f` frequency in Hz, `t` time in s, `n` sample index, `sr` sample rate,
`U(a,b)` uniform random, `N(0,σ)` Gaussian, `x mod m` modulo.

How sourcing works here:
- **Quote [verified]**: I read the text at the URL during this research pass.
- **Quote [secondary]**: the words are a summary or paraphrase from a review, label
  text or bio. They are not the artist's own words.
- **[reconstruction]**: an inference from the records or from the classic literature.
  No interview states it.
- Where I could not find a claimed technique in any source, I say so. This applies to
  the brief's "Evol Shepard/Risset rolls" and "Barbieri ratcheting" items.

---

## 1. Evol (Roc Jiménez de Cisneros, with Stephen Sharp)

Sources:
- FACT 2012 interview: https://factmag.com/2012/04/16/evol-on-rave-synthesis-hoover-abuse-making-computer-music-for-hooligans
- FACT on *Wormhole Shubz*: https://factmag.com/2012/01/26/evol-wormhole-shubz-2
- Editions Mego announcement: https://factmag.com/2013/02/07/editions-mego-announce-new-album-from-rave-deconstructionists-evol
- MACBA Son[i]a #209 podcast: https://rwm.macba.cat/en/podcasts/sonia-209-evol-2

Core stance: "Rave Synthesis". This is "a recontextualisation of popular techno sounds,
such as 'The Hoover' or the supersaw" (FACT 2012) [verified]. The duo started on drum
machines (a Yamaha RY-30), which taught them "periodicity, symmetry, decision-making,
time flow" [verified].

- **One-sound pieces.** *Wormhole Shubz* takes all of its material from a single preset,
  the Roland Alpha Juno "What the?" Hoover. The monophonic sound never breaks. The only
  counterpoint comes from frequency phasing (FACT review) [secondary]. Of *Proper
  Headshrinker*, the review says "the only variation comes from subtle phase
  modulations" [secondary].
  **DSP recipe:** one Hoover-like voice (a detuned saw stack with PWM and a pitch-bend
  envelope dipping −12 st). Duplicate it, slowly modulate the phase or delay offset of
  one copy (`adelay` with an LFO via `aevalsrc` or `aphaser`), sum, and keep that one
  sound running for the whole piece.

- **"Rave slime": stretching and folding (homeomorphism).** Rave sounds are abstracted
  from their original context, put into a beatless field, then time-stretched and
  "folded". The duo borrow homeomorphism from topology for how "tone bends" through the
  structure (Mego announcement) [secondary].
  **DSP recipe:** take a 0.5–2 s stab. Stretch it ×20–×200 with `rubberband`, or by
  granular overlap-add (OLA). Map one continuous parameter (pitch bend, cutoff, detune)
  along a smooth monotone curve so the piece is one continuous deformation: no cuts and
  no new material.

- **Supersaw abuse, stabs, "stripped-down acid".** Their later material is "a bit more
  stabby, or even a sort of stripped-down acid" (FACT 2012) [verified].
  **DSP recipe:** a 7-saw supersaw (detunes about ±0, ±11, ±22, ±35 cents, mixed into a
  shared high-pass) with a 30–80 ms amplitude envelope. Retrigger it on a sparse,
  irregular grid. Acid: one saw through a resonant low-pass whose cutoff gets an
  exponential decay per note and a high Q.

- **Acoustic emulation of synthetic sounds.** They imitate Hoovers and supersaws with
  balloons, hex nuts and gas horns played by the audience from simple instructions
  (FACT 2012) [verified].
  **DSP recipe:** emulate in the opposite direction. Resonant noise bands (a bank of
  `bandpass` filters on `anoisesrc`) shaped so that they "pretend" to be a saw chord.

- **Shepard/Risset glissandi and "rolls" [reconstruction; no interview found].** The
  brief credits Evol with Shepard tones and computer-mapped rolls. I found no interview
  text that confirms it. These pieces sit naturally inside the Rave Synthesis logic:
  the Hoover's signature downward bend, made endless.
  **DSP recipe (Shepard–Risset glissando):** use K = 8–10 sines spaced an octave apart:
  `f_k(t) = f0 · 2^((k + r·t) mod K)`. The amplitude of each is a raised-cosine bell over
  log-frequency, `A = 0.5 − 0.5·cos(2π·((k + r·t) mod K)/K)`. Set `r` = ±0.05–0.2 oct/s.
  Apply the same construction to a Hoover voice in place of sines for an "endless
  Hoover". Integrate phase per partial (`aevalsrc` with `st()`/`ld()`), because
  `sin(2π f(t) t)` is wrong for time-varying f.
  **DSP recipe (Risset rhythm / endless roll):** layer the same snare-roll pattern at
  tempo ratios 1, 2, 4, 8. Accelerate all of them by `2^(t/T)` and crossfade the layers
  with a log-tempo bell. The result is a roll that accelerates forever.

---

## 2. Florian Hecker

Sources:
- Tone Glow 226 interview: https://toneglow.substack.com/p/tone-glow-226-florian-hecker
- Neural.it: https://neural.it/2014/03/florian-hecker-sonic-experimentation-in-between-practices/
- MIT Arts on Chimerizations: https://arts.mit.edu/visiting-artist-florian-hecker-releases-chimerizations
- documenta 13: https://d13.documenta.de/programs/the-kassel-programs/some-artworks-and-programs-initiated-by-documenta-13-participants/chimerizations-and-speculative-solutions/
- Wikipedia: https://en.wikipedia.org/wiki/Florian_Hecker

- **One generator, no mixing.** He prefers "only one tool, concept, or algorithm as the
  sound source", "mainly by avoiding the concept of mixing several sound sources
  altogether", because "any additional processing might diminish qualities rather than
  support them" (Tone Glow) [verified].
  **DSP recipe:** each piece is one `aevalsrc` expression or one synthesis algorithm.
  Spatialise by giving each process its own channel, never by summing.

- **GENDYN (Xenakis dynamic stochastic synthesis), via Alberto de Campo's
  SuperCollider port.** *Kanal GENDYN* (2011, Mego) documents a 2004 Haswell & Hecker
  performance that used only this algorithm. "Alberto made a version of Xenakis' GENDYN
  algorithm at the time" (Tone Glow) [verified]. For the algorithm, see the Xenakis
  section.
  **DSP recipe:** one waveform period with N breakpoints. On each new period, every
  breakpoint's duration and amplitude takes a random-walk step (Cauchy or logistic
  distribution). Each walk is folded back into bounds by reflecting barriers
  ("mirrors"). Interpolate linearly between breakpoints.

- **Wavesets (after Trevor Wishart), real-time.** He fed GENDYN output into a waveset
  process that de Campo built after Wishart [verified].
  **DSP recipe:** split the signal at upward zero crossings into "wavesets". Then
  repeat each one k times (time-stretch with no pitch change), omit every m-th one,
  reverse each, or substitute a sine of the same length. These are pure index
  operations on zero-crossing segments.

- **Millisecond time shifts and Gestalt.** Intensity comes from "time-shifts in
  milliseconds, particular pitch relations, or concepts stemming from visual Gestalt
  theory" (Tone Glow) [verified].
  **DSP recipe:** send the same signal to L and R with an inter-channel delay swept
  from 0 to 30 ms. This crosses the boundary between fusion, precedence effect and
  echo, and a lateralised image moves with no change to the sound itself (`adelay` per
  channel).

- **Chimerization (auditory chimeras, after Smith, Delgutte & Oxenham 2002).** The
  process "swaps, trades, and extrapolates different qualities embedded within the
  time structures of each sound" (documenta) [secondary]. Hecker places it in the gap
  "between the voice and the non-voice" (Neural.it) [secondary]. Each source was a
  voice recorded in an anechoic room.
  **DSP recipe:** run sources A and B through the same N-band filterbank (N = 1, 4, 16,
  64). In each band, take the Hilbert envelope of A and the temporal fine structure
  (TFS) of B, form `env_A · cos(phase_B)`, and sum the bands. At low N, speech
  intelligibility follows the envelope. At high N, perceived pitch follows the TFS.
  Sweep N over time to move between word and non-word.
  ffmpeg-only approximation: `afftfilt` can compute magnitude from A only if A and B
  are interleaved as channels. In practice, render the bands with `bandpass` and use a
  rectifier plus low-pass as a crude envelope.

- **Iterative resynthesis with debris.** Some pieces use "iterative optimization steps,
  guided by gradient descent". Unfinished steps leave "debris or remnants" (Tone Glow)
  [verified]. Audiology analysis tools are repurposed for synthesis. One piece, *Syn
  As Tex*, runs about 53 hours.
  **DSP recipe:** keep a target texture's statistics (subband envelope means,
  variances, correlations; McDermott–Simoncelli texture statistics). Start from noise
  and nudge the subbands toward the target over K iterations. Record every
  intermediate iteration in sequence, so the piece *is* the convergence.

- **Automated seriation and arrangement.** *Synopsis Seriation* is an "automated
  arrangement of four three-channel pieces into one long continuous stereo
  arrangement". *Natural Selection* (2026) uses "automated file selection,
  database-generating sequencing systems" (Tone Glow) [verified].
  **DSP recipe:** segment the corpus. Compute a feature vector per segment (spectral
  centroid, flatness, RMS). Order the segments by a seriation algorithm (a 1-D
  embedding or a nearest-neighbour tour) and `concat` them.

- **Influences: Roads' PulsarGenerator and CloudGenerator.** "It sounded intense,
  direct, and raw" (Tone Glow) [verified]. See the Roads section. The brief also lists
  Tenney and Kanal: "Kanal" refers to *Kanal GENDYN*. I found no Hecker interview text
  on Tenney.

---

## 3. Caterina Barbieri

Sources:
- Sound On Sound interview: https://www.soundonsound.com/node/4917144
- RA review of *Patterns of Consciousness*: https://ra.co/reviews/20653
- Label text: https://www.fusetronsound.com/products/barbieri-caterina-patterns-of-consciousness-1
- NPR 2022: https://www.npr.org/2022/07/09/1110267969/caterina-barbieris-rapturous-electronica-was-forged-in-deep-solitude
- NPR *Math of You*: https://www.npr.org/sections/now-playing/2023/06/22/1183248289/caterina-barbieri-math-of-you

- **One harmonic oscillator plus one indexed sequencer.** *Patterns of Consciousness*
  (2017) used only an Orthogonal Devices ER-101 four-track sequencer and a Verbos
  Harmonic Oscillator. She starts from a full spectrum and filters it down to partials
  to "derive melodic material from the harmonic continuum" (SOS) [verified summary].
  **DSP recipe:** additive synthesis of partials 1..32 of a fixed f0. Melody is *which
  partial set is open*, not pitch change: the gain of partial k at time t is
  `g_k(t) ∈ {0,1}` from a sequencer. Use a `sine` per harmonic and `volume` with
  `eval=frame`, or one `aevalsrc` summing `sin(2π k f0 t)·g(k,t)`.

- **Arithmetic, geometric, random and jitter operations on long patterns.** The ER-101
  is "the brain of my setup". It writes "super long patterns" and applies math
  operations to them (SOS) [verified]. The label text says she derived "a myriad of
  interlocking patterns extracted from an original matrix of just few harmonic
  archetypes" by "subtraction, addition, and jitter" [secondary].
  **DSP recipe:** use a pattern `P[i]` of scale degrees, length L. Derive variants:
  - transpose: `P[i] + c`
  - geometric: `round(P[i]·c)`
  - jitter: `P[i] + U{−1,0,1}` with probability p
  - subtract: drop indices where `i mod m == r`

  Run 2–4 variants simultaneously at the same rate so their phase relationships do the
  composing.

- **The gate as the score: subtractive composition.** A gate track decides which part
  of the stored pattern actually sounds: "the key of a subtractive compositional
  design" (SOS) [verified]. Composing is "an act of subtraction rather than a
  demiurgic act of creation from scratch" [verified].
  **DSP recipe:** pitch row P (length 7) × gate row G (length 5, e.g. `1 0 1 1 0`).
  At step i, play `P[i mod 7]` if `G[i mod 5]`. The composite repeats after
  lcm(7,5) = 35 steps. Add a third row for octave (length 3) to get lcm = 105.
  Moving the G length from 5 to 6 changes the whole piece.

- **Fast arpeggios as sustained chords.** "Fast arpeggios are employed to get effects of
  sustained chords and overcome the limits of fast decay timbres" (label text)
  [secondary].
  **DSP recipe:** cycle a 3–5 note chord at 12–30 notes/s with short (20–60 ms)
  envelopes. Above roughly 15 Hz, the arpeggio fuses into a chord with roughness.
  Sweep the rate across the fusion threshold (about 8–20 Hz) as a structural
  parameter.

- **Simple waveforms, iconic-timbre avoidance.** She uses simple waveforms so the
  source stays blurred (SOS) [verified].
  **DSP recipe:** sine or triangle plus a gentle low-pass, and nothing else.
  Expressiveness comes from sequence and delay.

- **Multi-layered delay lines.** Modular output goes to Ableton ping-pong delays (SOS)
  [verified]. Live, the room's response to opening and closing filters matters (NPR/RA).
  **DSP recipe:** `aecho` with delays tuned to rational multiples of the step period
  (e.g. 3/4, 5/4, 7/4 steps) and feedback decays 0.4–0.7. The echoes become extra
  canonic voices offset in time, a free polyrhythm.

- **Alternative tunings via SuperCollider** [verified mention].
  **DSP recipe:** map scale degree d to `f0 · r_d`, with r from a just or harmonic
  series (the Verbos already gives harmonics 1..n, so the "scale" is the harmonic
  series itself).

- **Not verified:** ratcheting and Buchla-specific sequencing. She encountered the
  Buchla 200 at EMS Stockholm in 2013 (SOS), but I found no text on ratcheting.
  **DSP recipe if wanted:** a ratchet is k evenly spaced retriggers inside one step,
  `k ∈ {1,2,3,4}` chosen per step from a pattern.

---

## 4. Ryoji Ikeda

Sources:
- Wikipedia: https://en.wikipedia.org/wiki/Ryoji_Ikeda
- Forma on *datamatics*: https://www.forma.org.uk/projects/datamatics
- Plank review: https://www.plankmagazine.com/node/1746
- e-flux: https://www.e-flux.com/announcements/273095/ryoji-ikedaa-cosmic-journey-from-infinitesimal-to-astronomical

- **Sine tones at the edges of hearing.** His music "often uses frequencies at the
  edges of the range of human hearing" (Wikipedia) [secondary]. *+/-* (Touch, 1996)
  ends with a high tone that the listener notices "only upon its disappearance"
  (Ikeda, CD booklet, as quoted widely) [secondary].
  **DSP recipe:** a 16–19 kHz sine at −30 dBFS under the whole track that cuts at the
  end. Also use 20–40 Hz sines felt as pressure. Use `sine=f=18000` and
  `sine=f=30`.

- **Test-signal vocabulary: sine, white noise, impulse, sweep.** Ikeda's palette is
  "binary information, sine waves and white noise" (Plank) [secondary]. The materials
  of *Test Pattern* and *dataplex*:
  - 1-sample clicks
  - DC-offset steps
  - full-scale white noise bursts
  - logarithmic sweeps
  - 1 kHz reference tones

  **DSP recipe:** a vocabulary of exactly five atoms: `sine`, `anoisesrc=color=white`,
  a Dirac impulse (`aevalsrc='if(eq(n,0),1,0)'`), an exponential sweep
  (`f(t) = f1·(f2/f1)^(t/T)`), and silence. Sequence the atoms on a 1–5 ms grid.

- **Data to binary to sound (*test pattern*, *datamatics*).** *Datamatics* uses "2D
  sequences of patterns derived from hard drive errors and studies of software code"
  (Forma quoting The Wire) [secondary]. *data.scan* reduces DNA sequences, Morse code
  and particle data to pixels (e-flux) [secondary]. In *test pattern*, every bit of a
  barcode or data stream becomes a click or noise slice, synchronous with the image.
  **DSP recipe:** read any file as bytes. Each bit → a 1 ms frame. Map 1 to a full-
  scale click or 1–2 ms noise burst and 0 to silence (or 1 to sine A, 0 to sine B:
  FSK). At sr = 48 kHz with 48 samples/bit, 1 kB of data lasts 8 s. The `-f u8 -ar ...`
  raw input trick turns literally any file into a waveform.

- **Silence and extreme dynamics.** Hard gates, abrupt cuts to digital zero, and
  full-scale impulses next to silence.
  **DSP recipe:** at segment boundaries, zero all samples, with no fades. Allow DC
  steps that produce clicks deliberately.

- **Beating from close sines and phase/interaural play** [reconstruction from
  *Matrix* and *+/-*]. In the *matrix* room installation, sine fields are tuned so that
  standing waves and interference move as the listener moves.
  **DSP recipe:** use sine f in L and f+Δ in R with Δ = 0.5–8 Hz (binaural beat), or
  both summed in mono (acoustic beat). Room nodes: hold several sines whose
  wavelengths are near room dimensions (about 40–200 Hz).

- **Grid precision at sample scale.** Rhythmic material on a ms grid with tempo-locked
  clicks, plus a "1 bit / 1 frame" relation between audio and video.
  **DSP recipe:** generate the click track with
  `aevalsrc='if(eq(mod(n, N),0),1,0)'`, with N in samples (e.g. N = 2400 for 20 Hz).
  At N < 50 (≈ 1 kHz), the click train becomes a pitch (pulse → tone continuum).

---

## 5. Mark Fell

Sources:
- Quietus, Fell & Treanor: https://thequietus.com/articles/29266-rian-treanor-mark-fell-interview
- CCRMA *Multistability* Q&A: https://ccrma.stanford.edu/events/mark-fell-multistability-qa
- Raster *Multistability*: https://raster-media.net/shop/multistability
- Laboral bio: https://laboralcentrodearte.org/en/artists-curators-and-researchers/mark-fell-3/
- *Infoldings* (with Will Guthrie): https://hardwax.com/18181/mark-fell-and-will-guthrie/infoldings/
- *Intra*: https://fusetronsound.com/products/fell-mark-intra
- Quietus Baker's Dozen: https://thequietus.com/?p=16444

- **Multistability: rhythms that refuse one reading.** "Multistability" is the Gestalt
  term for an ambiguous figure that flips between interpretations (Raster) [secondary].
  The record explores "erratic and non-regular rhythmic patterns" (CCRMA) [secondary].
  **DSP recipe:** use one event stream whose inter-onset intervals (IOIs) sit between
  two meters. Example: IOIs alternate 3 and 4 sixteenths but are slowly interpolated
  toward 3.5/3.5, so the ear keeps flipping between a swung 4/4 and a straight 7.
  Slowly modulate a swing parameter `s ∈ [0.5, 0.75]` so the grid passes through
  ambiguous ratios.

- **Instruments, not tracks: rebuilt drum machines in Max.** He started by rebuilding an
  808-style interface in Max, then asked what functions the original lacked (Quietus)
  [verified summary]. He treats the patch or system as an artwork in itself.
  **DSP recipe:** a 16-step trigger grid where every step has per-step parameters
  (pitch, decay, pan, micro-offset). Expose a few global meta-parameters that rewrite
  the grid (rotate, invert, probability, step-length) and automate those. The
  "composition" is the meta-parameter trajectory.

- **Permutation of cut material.** For a voice piece he cut syllables and would
  "rearrange those according to some kind of permutation", making hybrid words
  (Quietus) [verified].
  **DSP recipe:** slice a recording into k segments (`atrim`). Concatenate them in
  permutation order π, stepping π through lexicographic order or through Steinhaus–
  Johnson–Trotter (adjacent swaps), so successive bars differ by one transposition.

- **Rules and density caps: game procedures.** In a workshop with four interlocking
  patterns, he capped density at three events per rhythmic grid, which made people
  place their events deliberately. "Games are meaningful because of the rules that you
  follow" (Quietus) [verified].
  **DSP recipe:** use V voices on a shared 16-step grid with a global constraint of at
  most 3 onsets per step across all voices, or at most k per voice per bar. Generate
  by random proposal plus constraint rejection.

- **Unfamiliar timing and tuning systems: Carnatic tala, gamelan.** *Multistability*
  and *UL8* "explore a number of unfamiliar timing and tuning systems" (Laboral)
  [secondary]. *Intra* draws on Carnatic tala: 7 structures × 5 jati variations = 35
  combinations (label text) [secondary]. *Infoldings* has Guthrie play against
  patterns from Fell's Max patches, probing gamelan and Carnatic rhythmic signatures.
  **DSP recipe (Suladi Sapta tala):** a tala is a sequence of angas (laghu of length
  `j ∈ {3,4,5,7,9}`, dhrutam = 2, anudhrutam = 1). Dhruva tala = laghu + dhrutam +
  laghu + laghu, giving cycle length `3j + 2`. Generate accents on anga starts and
  run the same pattern in two jatis simultaneously.

- **Quantization abuse and FM/DX-style timbres** [reconstruction from the records and
  his SND history]. Typical Fell gestures:
  - house chords from FM/Yamaha preset timbres, stuttered on micro-grids
  - swing values pushed to extremes
  - very short gate times turning chords into clicks

  **DSP recipe:** 2-operator FM, `sin(2π f t + I·sin(2π r f t))`, with index I
  decaying fast. Retrigger at grid divisions from 1/16 down to 1/128 and quantize
  onset times to a coarse grid that drifts against the pulse. Short gates (5–20 ms)
  turn chords into pitched clicks.

- **Rian Treanor: small components, minimal instrumentation.** Patches are "made from
  small components that are simple to understand on their own". A track should be "a
  drum pattern and one synth line" (Quietus) [verified].

---

## 6. Autechre (Sean Booth, Rob Brown)

Sources:
- Peter Hollo interview, 2005: https://aepages.org/wiki/Sean_Booth_Interview_taken_by_Peter_Hollo,_March_2005
- aepages *Confield*: https://aepages.org/wiki/Confield
- Pitchfork 2018 (NTS Sessions), via aepages: https://aepages.org/wiki/index.php?oldid=1869

- **Counter-driven Max sequencers.** "VI Scose Poise" was "a process made in Max". It
  "had various counters that would instigate various changes in the way the patch"
  behaved (Hollo 2005) [verified].
  **DSP recipe:** several counters with coprime moduli (e.g. 5, 7, 11, 13). Each
  counter's wrap event toggles a rule: swap the drum sample, shift the accent, change
  the step length, invert the velocity curve. The structure emerges from the counters'
  LCM, 5005 steps here.

- **Generative = controlled rules, not random.** Booth rejects "generative means random"
  (SOS 2004, via search summary) [secondary]. "If it did something wrong we'd change
  whatever variable it was that was making it go wrong" (Hollo) [verified].
  **DSP recipe:** use deterministic rules plus seeded PRNG. Render, listen, edit the
  rule constants, and re-render. Keep the seed fixed so edits are attributable.

- **Fader-controlled live state.** For "Uviol", the custom sequencer "changed what it
  was generating according to parameters we set with faders". Sequencers came first
  and "we'd mess around with the parameters in order to make the music later" (Hollo)
  [verified]. The NTS Sessions and the *elseq* series are long recordings of this
  live system.
  **DSP recipe:** a fixed generator with 4–8 continuous parameters (density,
  probability of a rest, pitch spread, swing, filter). The piece is a hand-drawn or
  random-walk automation curve per parameter, sampled per bar.

- **Non-timeline sequencing.** "Most of our best work has been made on non-timeline
  sequencers" (Hollo) [verified]. *Untilted* ran "loads of different sequences all
  running together".
  **DSP recipe:** several loop-sequencers of different lengths running free, with no
  global arrangement timeline. The arrangement is when voices are muted or unmuted.

- **Self-retriggering delay.** Some sounds came from a drum machine through a delay
  "being re-triggered by its own output" (Hollo) [verified].
  **DSP recipe:** a feedback delay whose output drives an envelope follower that
  re-fires the source. In ffmpeg (no cycles in graphs), iterate: render
  `y_{k+1} = x + g·delay(y_k)` across passes, or use `aecho` with high decay and
  multiple taps.

- **Physical modelling of drums offline; samples disguised.** "A lot of our music is
  sample-based" [verified]. Booth prefers modelling in "non-realtime situations".
  **DSP recipe:** Karplus–Strong or modal drums (a bank of decaying sines at
  inharmonic ratios such as 1, 1.59, 2.14, 2.30 for a membrane) excited by short noise
  bursts.

- **Tempo and grid warping** [reconstruction from *Confield*, *Draft 7.30*]. Their
  rhythms often have IOIs drifting continuously (accelerando or decelerando inside a
  bar) while other voices stay fixed.
  **DSP recipe:** onset times `t_i = T·(i/N)^γ` per bar, with γ ∈ [0.7, 1.4] slowly
  modulated. One voice keeps γ = 1 as a reference.

---

## 7. Oval (Markus Popp)

Sources:
- FACT 2013: https://factmag.com/2013/04/09/it-was-sort-of-commercial-suicide-oval-revisits-his-ambient-masterpiece-94diskont
- Disquiet 1997: https://disquiet.com/1997/08/15/popp-music/
- Bandcamp Daily guide: https://daily.bandcamp.com/lists/oval-album-guide

- **Prepared CDs (skips and stutters as material).** Hand-marked discs (Bandcamp
  quotes non-permanent marker on rented CDs) produce laser skips. These are sampled,
  looped and edited [secondary]. Glitch is "a means or a method to surprise myself,
  without being random" (FACT) [verified].
  **DSP recipe:** emulate a CD skip. Take a source and read it in 1/75 s frames (CD
  sector timing ≈ 13.3 ms; 588 stereo samples per frame). At random or patterned
  points, jump the read head back by k frames and loop a 1–8 frame block several
  times, causing hard discontinuities. Add a short mute (error concealment) or a
  sample-hold. Implement with `atrim` and `aloop=loop=k:size=588*m` and `concat`.

- **Tiny sampler memory forces loop structure.** *Systemisch* was made on an
  "entry-level Yamaha sampler with 50 seconds of sampling memory" (FACT) [verified].
  **DSP recipe:** a hard budget: the piece may use only 50 s of source audio total.
  Everything is loops of slices of that buffer.

- **Hand-crafted linear "songs" from the "most unlikely building blocks".** These are
  "very deliberate, linear, hand crafted songs" (FACT) [verified].
  **DSP recipe:** skip loops chosen by ear for pitch content (a loop of length L
  samples has pitch sr/L, so a 588-sample loop is 81.6 Hz at 44.1 kHz). Choose loop
  lengths to form a scale: L = sr / f_target.

- **Distributed playback.** In the "Do While" installation, "every sample the track
  consisted of was played back from a different speaker" (FACT) [verified].
  **DSP recipe:** a multichannel render where each loop gets its own channel
  (`amerge` to N channels), with no mixdown.

---

## 8. Kevin Drumm

Sources:
- Wikipedia: https://en.wikipedia.org/wiki/Kevin_Drumm
- Quietus "Strange World Of": https://thequietus.com/?p=257497
- FACT beginner's guide: https://factmag.com/2013/07/08/a-beginners-guide-to-kevin-drumm

- **Prepared guitar.** Magnets, binder clips, chains, bow, and clippers on strings
  (Wikipedia) [secondary].
  **DSP recipe:** a plucked string (Karplus–Strong) with a nonlinear "buzz" (hard clip
  inside the loop) and a moving damping point (comb notch position modulated).

- **Walls of saturated noise: *Sheer Hellish Miasma* (2002).** Guitars, tapes, pedals,
  analog synth and computer, with Greg Kelley's trumpet "pulverised out of
  recognition" (Quietus) [secondary].
  **DSP recipe:** layer pink and brown noise with a slowly swept resonant band-pass.
  Drive through cascaded hard clippers (`acrusher` or `aeval='tanh(k*val(0))'` with
  k = 10–100). The saturated spectrum flattens, and movement comes from pre-clip
  filtering. Keep it at full scale for 20+ minutes.

- **Long, near-static drones: *Imperial Distortion* (2008), *Necro Acoustic*.**
  Originally conceived as "primal fuzz pedal experiments"; the finished album is
  recordings from 1995–2008 (FACT via Dennis Cooper's blog) [secondary].
  **DSP recipe:** 2–4 low sines or organ-like tones with very slow (≥ 60 s) amplitude
  crossfades. Add low-level hiss. Changes are almost imperceptible; this is the
  Radigue crossfade logic applied to fuzz textures.

---

## 9. Sarah Davachi

Sources (general; I did not fetch a technique interview, so items are
[reconstruction] from widely reported practice):
- Mellotron, organs, bowed strings and voice, recorded close and slowed.

- **Sustained acoustic tones, overtone focus.** Pieces centre on long single tones
  from acoustic instruments, letting upper partials and attack transients unfold.
  **DSP recipe:** take a short instrument note and time-stretch it ×4–×16 while
  preserving partials (`rubberband` with formant preservation), then crossfade
  successive stretched notes with 5–20 s overlaps.

- **Tape-speed transposition (varispeed).** Slowing a recording lowers pitch and
  stretches time together.
  **DSP recipe:** `asetrate=sr*r,aresample=sr` with r = 0.5 (octave down) or r = 2/3
  (a fifth down). Layer the original with its r = 1/2 copy for octave doubling, with
  timbral "darkening".

- **Just-intoned unisons and slow beating.** Near-unisons from multiple players or
  takes produce slow beating, which is the music's internal motion.
  **DSP recipe:** sines at f, f·(1+ε) with ε ≈ 0.001–0.005, giving beating at f·ε
  (e.g. 0.2–1 Hz at 200 Hz).

---

## 10. Kali Malone

Sources:
- Wikipedia: https://en.wikipedia.org/wiki/Kali_Malone
- Rewire / Tiny Mixtapes interview: https://www.rewirefestival.nl/feature/kali-malones-lp-the-sacrificial-code-reviewed
- RA review of *All Life Long*: https://ra.co/reviews/35960
- Futurism Restated: https://futurismrestated.substack.com/p/futurism-restated-51-kali-malone

- **Just intonation on pipe organ.** *The Sacrificial Code* (2019) is in 11-odd-limit
  just intonation, on three organs (Wikipedia) [secondary]. She learned the organ by
  tuning it as an apprentice to tuner Jan Börjeson [secondary].
  **DSP recipe:** use a scale from 11-odd-limit ratios: 1/1, 12/11, 11/10, 9/8, 8/7,
  7/6, 6/5, 11/9, 5/4, 9/7, 4/3, 11/8, 7/5, 10/7, 16/11, 3/2, 14/9, 8/5, 18/11, 5/3,
  12/7, 7/4, 16/9, 9/5, 20/11, 11/6, 15/8, 2/1 (pick a subset). Organ pipe tone =
  additive sines with partials 1..8 at amplitudes ~1/k^1.5, plus a slight noise
  "chiff" on attack.

- **Rule-based procedure against stasis.** Free improvisation drifts toward static
  drones, so she "uses very rule-based methods to push against her desire for stasis"
  (Tiny Mixtapes via Rewire) [secondary].

- **Canons.** "All Life Long" appears twice: an extended organ canon and a short vocal
  arrangement. The album alternates brass, organ and voice asymmetrically across 78
  minutes (reviews) [secondary]. In her slow canons, the same chorale line enters in
  successive voices at fixed offsets, sometimes in augmentation, producing slowly
  shifting vertical just-intonation sonorities.
  **DSP recipe:** a chorale line M (sequence of JI ratios and durations). Voice v plays
  M delayed by v·D and time-scaled by a_v (e.g. a = 1, 2, 4 for mensuration canon).
  Sum the voices. Every vertical is a JI chord by construction; beating between
  near-coincident partials (e.g. 7/4 vs 16/9) gives slow shimmer.

- **Permutation of chord sequences** [reconstruction]. In some Malone pieces, a fixed
  set of chords is stepped through orderings.
  **DSP recipe:** a fixed set of 4–6 JI chords, played in all orderings of a cyclic
  rotation with long (20–40 s) crossfades.

---

## 11. Éliane Radigue

Sources:
- Bob Gluck interview, *Array*: https://journals.qucosa.de/array/article/download/2475/2319/4079
- Rubin Museum: https://rubinmuseum.org/spiral/composing-a-life
- Blank Forms: https://www.blankforms.org/eliane-radigue-works-for-magnetic-tape-1968-1999
- Electronic Beats: https://www.electronicbeats.net/eliane-radigue-an-interview

- **Microphone–loudspeaker feedback, then tape loops (1960s–70).** Her early work with
  Pierre Henry relied on feedback between a mic and a speaker to make elongated tones
  [secondary].
  **DSP recipe:** feedback is a recursive comb-like loop. Loop gain slightly below 1
  through a room's response H(f): y = x + g·H*y. It rings at the peaks of H. Emulate
  with `afir` using a short room impulse response, iterated across passes (render
  y_k, convolve, add, re-render), or with `aecho` delays of 3–20 ms and decay 0.8–0.95
  plus a resonant `bandpass` in the chain.

- **Beats as the core sensation.** She was "fascinated in particular by the sounds
  produced by beats and the sensations that were produced by these means" (Gluck)
  [secondary].
  **DSP recipe:** 2–6 sines within a few Hz of each other (e.g. 110, 110.3, 110.7,
  220.4). The beating pattern is a slow, quasi-periodic amplitude texture. Vary Δf by
  0.01 Hz steps over minutes.

- **ARP 2500: micro-adjustments, no keyboard.** "very slight changes, such as moving a
  knob very slightly" gave almost unnoticeable changes. She wanted to work with "the
  sounds within the sounds" (Gluck) [secondary]. She never used the keyboard.
  **DSP recipe:** oscillators with linear drift: f(t) = f0 + δ·t with δ ≈ 0.001 Hz/s.
  Every parameter moves on hour-scale ramps.

- **"Only one trick: the cross-fade."** Long tones were recorded to tape and then very
  slowly crossfaded (Blank Forms/Artforum) [secondary].
  **DSP recipe:** a chain of 5–10 min sections. Each transition is an equal-power
  crossfade of 2–5 min (`acrossfade=d=180:c1=qsin:c2=qsin`). The piece is a sequence
  of crossfades.

---

## 12. Alvin Lucier

Sources: Lucier, *Music 109* (Wesleyan UP, 2012); the score text of *I Am Sitting in a
Room* (1969); Wikipedia: https://en.wikipedia.org/wiki/I_Am_Sitting_in_a_Room

- **Iterated room re-recording (*I Am Sitting in a Room*, 1969).** The score text:
  "I am sitting in a room different from the one you are in now. I am recording the
  sound of my speaking voice and I am going to play it back into the room again and
  again until the resonant frequencies of the room reinforce themselves..." [score,
  widely reproduced].
  **DSP recipe:** `y_{k+1} = y_k * h` (convolution with room IR h) followed by
  normalization, repeated 16–32 times. Concatenate y_0..y_K. The output converges to
  the room's dominant modes: |H(f)|^k sharpens peaks. ffmpeg-native: loop
  `afir` + `loudnorm` / `dynaudnorm` over K passes in a shell script. This is the
  canonical "feedback across process invocations" form.

- **Close-tuned sines against an instrument (*Still and Moving Lines*, *Crossings*).**
  An instrument sustains a tone while a pure wave sweeps slowly through it, producing
  beats that speed up, stop at unison, and speed up again.
  **DSP recipe:** a fixed tone at f plus a sine sweep from f−10 to f+10 Hz over 60 s.
  Beat rate = |Δf|.

- **Standing waves and spatial interference (*Standing Waves*, *Music on a Long Thin
  Wire*).** Fixed sines in a room create nodes and antinodes; moving listeners hear
  timbral change.
  **DSP recipe:** stereo sines at f and f+0.1 Hz. The phase relationship rotates every
  10 s and the stereo image sweeps.

- **Brain waves to percussion (*Music for Solo Performer*, 1965).** EEG alpha (8–12 Hz)
  drives resonators and drums.
  **DSP recipe (sonification):** any slow control signal (data, an LFO) is band-limited
  to 8–12 Hz and used as amplitude excitation of low-frequency resonators (bandpass on
  noise at 40–80 Hz with high Q).

- **Bird and Person Dyning / sondols** [reconstruction]. Heterodyne and echolocation
  pieces exploit difference tones between close high sines.
  **DSP recipe:** two sines at 3000 and 3150 Hz, played loud. The ear generates the
  quadratic difference tone 150 Hz and the cubic difference tone 2f1−f2 = 2850 Hz.

---

## 13. James Tenney

Sources:
- *For Ann (rising)*: https://en.wikipedia.org/wiki/For_Ann_(rising)
- Tenney, *Meta+Hodos* (1961/1988)
- Polansky, "The Early Works of James Tenney", *Soundings 13* (1984)

- ***For Ann (rising)* (1969): a Shepard-like ascending glissando cascade.** Sine-tone
  glissandi each rise 8 octaves over about 33.6 s, with new entries at a fixed time
  offset, so that many overlap; each fades in and out at its ends. The interval
  between consecutive entries corresponds to roughly a minor sixth (or, depending on
  the realisation, a fixed proportion), so the overlapping glides form near-consonant
  intervals [reconstruction from standard analyses; check against Polansky].
  **DSP recipe:** glide g(t) = f_lo · 2^(8·t/33.6), from 40 Hz to 10240 Hz. Entries
  start every Δ s. Amplitude = sin²(π t / 33.6) bell. Sum about 33.6/Δ simultaneous
  glides. Phase must be integrated per glide.

- **Ergodic form.** Ergodic means every section is statistically like every other: no
  development, a "sound state" whose statistics are stationary.
  **DSP recipe:** choose a parameter distribution (pitch ~ U over a band, IOI ~ Exp(λ),
  amplitude ~ U) and sample it identically for the whole piece. Any 30 s excerpt is
  statistically interchangeable.

- **Stochastic computer works at Bell Labs (1961–64: *Noise Study*, *Stochastic
  Quartet*, *Phases*).** Parameters were drawn from distributions whose ranges
  (means and bandwidths) change over time via "tendency masks".
  **DSP recipe:** event pitch ~ U[lo(t), hi(t)], where lo and hi are piecewise-linear
  envelopes (tendency masks, also used by Koenig and Truax). Same for duration and
  amplitude. This is the cleanest "score as two curves" generator.

- ***Noise Study* (1961): band-limited noise shaped like traffic in the Holland
  Tunnel.**
  **DSP recipe:** white noise through band-pass filters whose centre frequencies and
  bandwidths follow random-walk tendency masks. Overlay multiple bands with
  independent AM.

- **Harmonic series and spectral canons (*Spectral Canon for Conlon Nancarrow*, 1974).**
  Voice k plays harmonic k of a fundamental, with a repeated-note rhythm accelerating
  at a rate tied to k.
  **DSP recipe:** for k = 1..24, a sine at k·f0 retriggered with IOIs following a
  log-spaced acceleration; voice k enters after voice k−1. The texture fuses into one
  harmonic-spectrum chord with rhythmic "spectral" grain.

- **Clang, sequence and Gestalt grouping (*Meta+Hodos*).** Temporal Gestalt: proximity
  and similarity determine where boundaries are heard.
  **DSP recipe:** structure segments by maximising feature distance at boundaries
  (pitch jump, timbre change) and minimising it inside segments.

---

## 14. Iannis Xenakis

Sources:
- Xenakis, *Formalized Music* (Pendragon, 1992)
- Serra, M.-H., "Stochastic Composition and Stochastic Timbre: GENDY3", *Perspectives
  of New Music* 31/1 (1993)
- Luque, S., "The Stochastic Synthesis of Iannis Xenakis", *Leonardo Music Journal* 19
  (2009)
- Wikipedia GENDYN: https://en.wikipedia.org/wiki/Dynamic_stochastic_synthesis

- **GENDYN (*GENDY3*, 1991; *S.709*, 1994): dynamic stochastic synthesis.** The
  waveform is a polygon of N breakpoints (N ≈ 5–30) per period. On every period, each
  breakpoint's amplitude a_i and duration d_i (in samples) receives a random step from
  a distribution (Cauchy, logistic, hyperbolic cosine, arcsine, exponential). This is
  a *second-order* random walk: the step itself random-walks, and both walks are
  bounded by reflecting "elastic mirrors". Pitch = sr / Σ d_i; timbre = polygon shape.
  **DSP recipe:**
  - `v_i ← mirror(v_i + Cauchy(0, s_v), ±V)`
  - `a_i ← mirror(a_i + v_i, ±1)`
  - `w_i ← mirror(w_i + Cauchy(0, s_d), ±W)`
  - `d_i ← mirror(d_i + w_i, [dmin, dmax])`

  Then linear-interpolate a_i over d_i samples. Narrow [dmin, dmax] gives stable
  pitch; wide gives glissando and noise. In ffmpeg, implement with
  `aevalsrc` + `st()`/`ld()` state (≤ 10 variables in older builds, so limit to
  N ≈ 3–4), or render via a tiny external generator and pipe raw PCM into ffmpeg.

- **Stochastic clouds (*Pithoprakta*, *Achorripsis*, *Analogique B*).** Event density
  per unit time ~ Poisson; inter-onset times ~ Exp(λ); pitch intervals ~ triangular
  distribution; glissando speeds ~ Gaussian (Maxwell–Boltzmann for gas molecules).
  **DSP recipe:** a Poisson process of grains or sine glissandi, with
  IOI = −ln(U)/λ. Each grain gets pitch ~ U or N and a glissando slope ~ N(0, σ).
  Vary λ and σ over time as the form.

- **Sieves (*Nomos Alpha*, *Jonchaies*, *Psappha*).** A sieve is a union and
  intersection of residue classes: e.g. `(8,0) ∪ (8,1) ∪ (8,7) ∪ (5,1) ∩ (3,2)`. Use
  it for pitch scales (in quarter- or semitones) or rhythms (on a pulse grid).
  **DSP recipe:** rhythm sieve: onset at step n if
  `(n mod 3 == 0 or n mod 4 == 0) and n mod 5 != 2`. Pitch sieve: allowed semitones
  {n : n mod 12 ∈ S1 or n mod 7 ∈ S2}. Implementable directly as `aevalsrc`
  expressions with `mod()`.

- **Markov chains of screens (*Analogique A/B*).** A "screen" is a time slice of
  (frequency × amplitude) cell densities; screens follow a Markov transition matrix.
  **DSP recipe:** 3–4 screen states, each a grid of grain densities over frequency
  bands. Pick the next screen by a transition matrix; render as granular clouds.

- **UPIC: drawn waveforms and pitch arcs (*Mycènes Alpha*, 1978).**
  **DSP recipe:** draw a curve → wavetable (one period); draw arcs → pitch trajectories
  over time. Any image row can become a waveform (bridges to Ikeda-style data-to-audio).

- **Brownian polygon (Polytope and Diatope texts).** Brownian pitch movement of
  instrument lines with reflecting boundaries.
  **DSP recipe:** f(t+Δ) = mirror(f(t)·2^(N(0,σ)), [f_lo, f_hi]) per voice, with
  10–50 voices.

---

## 15. Curtis Roads

Sources:
- Roads, *Microsound* (MIT Press, 2001)
- Roads, *Composing Electronic Music* (OUP, 2015)
- PulsarGenerator / CloudGenerator: https://www.curtisroads.net/
- Hecker on them (Tone Glow, above)

- **Granular synthesis: sound as clouds of 1–100 ms grains.** Grain parameters: onset
  density (grains/s), duration, waveform, envelope (Gaussian, Hann, expodec), pitch,
  and spatial position. A "cloud" is a time region with parameter ranges.
  **DSP recipe:** grain = window(t/dur)·sin(2π f t). Onsets Poisson at density ρ. Use
  dur ∈ [5, 50] ms and pitch ~ U[f_lo, f_hi]. A synchronous grain stream (fixed IOI)
  gives a pitch at 1/IOI (formant-like). Asynchronous streams give a noise cloud.

- **Pulsar synthesis.** A pulsar is a pulsaret (one cycle of an arbitrary waveform of
  duration d) followed by silence until the next period p. Fundamental = 1/p, formant
  = 1/d. Varying p and d independently gives separately controlled pitch and formant.
  "Pulsar masking" drops pulses by pattern, giving rhythm-to-tone continua.
  **DSP recipe:**
  `aevalsrc='if(lt(mod(t,P),D), sin(2*PI*mod(t,P)/D), 0)'`, with P = 1/f0 and
  D ≤ P. Sweep f0 from 1 Hz to 200 Hz to cross from rhythm to pitch. Add a binary
  mask on pulse index for stochastic or patterned dropping.

- **Time scales.** Infinite, supra, macro, meso, sound object, micro, sample,
  subsample. Composition happens at the boundaries: rhythm turns to pitch at about
  20 Hz, and pitch turns to timbre at grain sizes below about 50 ms.
  **DSP recipe:** any periodic event generator whose rate sweeps exponentially from
  2 Hz to 2 kHz, the single most reusable "microsound" gesture.

- **Transient drawing and "particle" editing.** Hand-placed clicks and micro-events,
  edited at the sample level.
  **DSP recipe:** a click track built from an explicit list of sample indices (a data
  file → `aevalsrc` via `if(eq(n,…))` or a generated raw PCM).

---

## 16. Maryanne Amacher

Sources:
- Wikipedia: https://en.wikipedia.org/wiki/Maryanne_Amacher
- Amacher, "Psychoacoustic Phenomena in Musical Composition" (1977; reprinted in
  *Maryanne Amacher: Selected Writings and Interviews*, Blank Forms 2020)
- *Sound Characters (Making the Third Ear)*, Tzadik 1999, liner notes
- CDM on the Otophon plug-in: https://cdm.link/otophon-is-a-plug-in-to-play-tones-inside-your-head/

- **"Third ear music": otoacoustic emissions and combination tones.** Two loud pure
  tones make the ear itself emit tones, heard "inside" the head. She used the term
  "ear tones" until 1992 [secondary]. Her goal was music that makes the ears "'sound'
  their own tones and melodic shapes" (liner notes) [secondary].
  **DSP recipe:** sines f1 < f2 with f2/f1 ≈ 1.1–1.3, at fairly high level (both in
  the 1–6 kHz region). The strongest emission is the cubic distortion product at
  2f1 − f2. Also present: the quadratic difference tone f2 − f1 and 3f1 − 2f2. To make
  an *ear melody*, keep f2/f1 constant at about 1.2 and move both: the phantom
  2f1 − f2 = f1·0.8 tracks. Or hold f1 and move f2 so that 2f1 − f2 traces a melody
  while the primaries barely change pitch. Do not do this on headphones at high level;
  she used speakers, and the effect does not occur with headphones.

- **Perceptual geography.** The composer coordinates the sounding source, the response
  tones in the ear, and the subjective impression (essay) [secondary].
  **DSP recipe:** in the score, list the target phantom pitch per section and solve for
  primaries (f2 = 2f1 − target). Fast patterned changes in primaries (10–20 Hz
  alternation) make the ear tones "dance".

- **Structure-borne sound and site specificity (*Music for Sound-Joined Rooms*).**
  Loud low tones carried through walls, so the building filters them.
  **DSP recipe:** source at full level → low-pass at 200–400 Hz plus a strong comb
  (wall resonances) via `afir` with a measured or synthetic "through-wall" IR.

---

## 17. Russell Haswell

Sources:
- *Kanal GENDYN* (Editions Mego, 2011), with Hecker: see Wikipedia Hecker above
- Haswell's UPIC works, *Live Salvage 1997→2000*

- **GENDYN performance (with Hecker, de Campo SC2 port).** See the Xenakis section.
- **UPIC live.** Drawn waveforms and arcs performed through Xenakis's UPIC system.
- **Live salvage: no-input/feedback, harsh digital processing** [reconstruction].
  **DSP recipe:** bit reduction and sample-rate reduction to near-zero resolution
  (`acrusher=bits=1..4:samples=8..64`). Pure digital square-wave rasp from 1-bit
  quantization of low-level noise.
- **Maximal dynamic contrast and sub-bass pressure** [reconstruction].
  **DSP recipe:** a 30–40 Hz square or sine with hard clip, alternating with digital
  silence.

---

## 18. Lorenzo Senni

Sources:
- FACT 2016: https://factmag.com/2016/10/25/lorenzo-senni-persona-warp-interview
- Truants 2018: https://truantsblog.com/2018/interview-lorenzo-senni
- Vice/Noisey: https://www.vice.com/en/article/lorenzo-senni-noisey-italy-interview
- Arturia: https://www.arturia.com/stories/lorenzo-senni
- WFDD: https://wfdd.org/story/songs-we-love-lorenzo-senni-rave-voyeur

- **"Pointillistic trance": the build-up without the drop.** He "sources, extracts and
  surgically links together the 'build-ups' from heaps of hardcore trance tracks". The
  drop is removed and euphoria deferred (WFDD) [secondary]. Early sets were built
  entirely of build-ups (Truants) [secondary].
  **DSP recipe:** a tension generator with no resolution. Use:
  - snare roll density doubling every N bars (1/4 → 1/8 → 1/16 → 1/32)
  - high-pass sweep up
  - rising pitch of a lead, or a Shepard–Risset rise for an endless build
  - noise riser

  Never let any parameter release.

- **JP-8000 supersaw in staccato points.** *Quantum Jelly* (2012) used the Roland
  JP-8000 supersaw preset [secondary]. His style became "a lot more exact and precise"
  after the JP-8000 (Arturia) [secondary].
  **DSP recipe:** a supersaw chord with a 10–40 ms envelope, sequenced in short
  arpeggiated patterns of odd length (e.g. 5 or 7 steps on a 16-step grid), with no
  kick or bass. The "points" are what is left of a trance riff when sustain → 0.

- **"Rave voyeurism".** Observing euphoria from outside rather than producing it;
  isolated stems from a genre.
  **DSP recipe:** remove the low end (high-pass at 150–300 Hz) from all trance
  material. Keep the gestures and drop the body.

---

## 19. Holly Herndon

Sources:
- Ableton blog, Jlin & Herndon: https://ableton.com/es/blog/jlin-holly-herndon-comparing-notes
- Various interviews on *Movement* (2012), *Platform* (2015), *PROTO* (2019), *Spawn*
  [reconstruction from widely reported practice]

- **Voice as laptop instrument (*Movement*, *Platform*).** Live voice processed in
  Max/MSP, with granular stutters, formant shifts, and her own voice cut into rhythmic
  material.
  **DSP recipe:** voice → granular slicer with grain size 20–80 ms, grain repeat
  driven by a step pattern. Pitch-shift each grain by a scale degree. Hard-gate to the
  grid.

- **Personal data and browser audio (*Chorus*, *Platform*).** Sounds recorded from her
  own browsing and computer activity.
  **DSP recipe:** sonify logs. Map events (keystrokes, network packets, timestamps) to
  onset times, and map byte values to pitch or grain index.

- **Neural voice model "Spawn" and Holly+ voice timbre transfer.** A trained network
  learns voices; the ensemble's voice becomes material.
  **DSP recipe (non-ML approximation):** spectral envelope transfer. Use the
  `afftfilt` magnitude of a voice-derived filter imposed on a source (cross-synthesis
  or vocoding with a bank of `bandpass` filters and envelope followers).

---

## 20. Jlin

Sources:
- Ableton blog: https://ableton.com/es/blog/jlin-holly-herndon-comparing-notes
- Fader 2017: https://www.thefader.com/2017/05/02/jlin-black-origami-interview
- Tone Glow 129: https://toneglow.substack.com/p/tone-glow-129-jlin
- Sound On Sound podcast (FL Studio chapter): https://www.soundonsound.com/node/4932035

- **Intuitive, from a blank page.** "It starts off as this pure, blank piece of paper
  then it begins to bend and fold", hence *Black Origami* (Ableton) [secondary]. "I
  don't operate in technicalities. I operate in intuition" (Grammy.com) [secondary].
- **Footwork-derived polyrhythm in FL Studio** [reconstruction from the records].
  Typical Jlin traits:
  - 160 bpm footwork pulse with triplet and quintuplet subdivisions overlaid
  - toms and metallic percussion pitched as melody
  - vocal fragments chopped to single syllables
  - patterns "folding" into each other: rhythms "shifting and morphing ... with
    mathematical precision" (Fader) [secondary]

  **DSP recipe:** at 160 bpm, play 16ths in voice A, 16th-triplets in voice B, and
  quintuplets in voice C, with each voice's onsets thinned by a different
  Euclidean pattern (E(5,16), E(7,24), E(4,20)). Pitch toms to a pentatonic set.
  Retrigger a 1-syllable vocal slice on accents.

---

## 21. 2025–2026 standouts (thin technique data)

- **Barker, *Stochastic Drift* (Smalltown Supersound, 2025).** The title is a
  navigation term for gradual random deviation. The thesis is "organic, human timing
  in a genre that has become increasingly obsessed with mechanized grids". The record
  uses mechanical acoustic instruments, more microphones and preamps, and fewer synths
  (RA Exchange: https://ra.co/exchange/825; First Floor:
  https://firstfloor.substack.com/p/in-a-volatile-world-barker-is-trying)
  [secondary]. An earlier Barker trait is kickless techno ("Utility", 2019).
  **DSP recipe:** a timing random walk. Onset_i = i·T + e_i with
  e_i = mirror(e_{i−1} + N(0, σ), ±E). Use σ ≈ 1–3 ms and E ≈ 15 ms: a GENDYN-like
  walk applied to the rhythmic grid, not to the waveform. Use mechanical-sounding
  sources (modal resonators struck by solenoid-like clicks).

- **Los Thuthanaka (Chuquimamani-Condori & Joshua Chuquimia Crampton), self-titled,
  2025** (Pitchfork's #1 of 2025). The production has "unmastered audio, clipping,
  static", plus guitars, synths, keytar, ronroco and bombo italaque
  (Wikipedia: https://en.wikipedia.org/wiki/Los_Thuthanaka) [secondary].
  **DSP recipe:** clipping as a compositional layer. Sum many layers, then hard clip
  (`alimiter` off; use `volume=+18dB,aeval='max(-1,min(1,val(0)))'`). Keep inter-sample
  overs and add static (sparse impulse noise, `anoisesrc` → gate at low probability).

- **Oneohtrix Point Never, *Tranquilizer* (2025).** Built from a large archive of
  1990s sample-CD audio (about 500 GB bookmarked, later vanished from the Internet
  Archive). It is "a return to a process-oriented form of music making", with material
  fed through "rudimentary sample-browsing software". Pre-fab beats and ROMplers are the
  starting point (Quietus: https://thequietus.com/?p=264380; Tone Glow 195:
  https://toneglow.substack.com/p/tone-glow-195-oneohtrix-point-never; Dazed:
  https://www.dazeddigital.com/music/article/69026/1/oneohtrix-point-never-daniel-loptin-interview-searching-soul-among-ai-slop)
  [secondary].
  **DSP recipe:** "browse-as-compose". Randomly audition 1–4 s windows of a large
  library, keep the "moments of magic" by a rule (e.g. spectral flatness below a
  threshold, or a high harmonic-to-noise ratio), and string them with crossfades.

- **Aya (*Hexed!*, 2024; *im hole*, 2021).** I found no concrete technique interview.
  The records use heavy vocal processing and broken club rhythm. Not used for recipes.

---

## Cross-cutting ideas for an ffmpeg-only genre

The goal is a set of reusable primitives and forms, each realisable as one ffmpeg
filtergraph (or a short loop of ffmpeg invocations), taking the artists above as
precedent.

### A. Primitives to build first

1. **Phase-integrated oscillator with state.** Almost every recipe needs f(t) that
   changes over time. `aevalsrc` with `st(0, ld(0) + 2*PI*f/sr)` accumulates phase.
   The variable store persists across samples (verified locally; see F). For
   exponential glides there is also a closed form:
   φ(t) = 2π f0 T (2^(t/T) − 1)/ln 2. Enables Shepard–Risset, *For Ann*, Lucier
   sweeps and Amacher ear melodies.
2. **Click and impulse train with sample-exact grid.**
   `if(eq(mod(n,N),0),1,0)`. Sweep N for the Roads rhythm-to-pitch continuum.
   Used by Ikeda and Senni.
3. **Seeded noise.** `anoisesrc=seed=…:color=white|pink|brown`. Gives GENDYN steps,
   Tenney masks and Xenakis clouds. Keep seeds in the score for reproducibility
   (Autechre's "change the variable that made it go wrong").
4. **Data → PCM.** `ffmpeg -f u8 -ar 8000 -ac 1 -i anyfile` reads any file as audio.
   Also use `-f s16le` for 16-bit. Enables Ikeda datamatics and Herndon log
   sonification. Bits → clicks via `aeval` thresholding.
5. **Iteration as feedback.** Filtergraphs are acyclic, so feedback happens *across
   passes*: render, process, re-feed. This is Lucier (*I Am Sitting*), Radigue tape
   generations and Autechre's self-retriggered delay. Make iteration count a
   first-class compositional parameter, and keep every intermediate pass as material,
   as Hecker does with his "debris".
6. **Convolution.** `afir` with any file as an impulse response: rooms, other pieces,
   a single sine burst (a resonator), or data files as IRs.
7. **Sample-rate abuse.** `asetrate` (varispeed: Davachi, tape), `aresample` with
   poor filters, `acrusher` (bit and sample-hold reduction: Haswell). Aliasing as
   timbre: generate sines above Nyquist on purpose (f > sr/2 folds to sr − f), so a
   rising sweep "reflects" downward.
8. **FFT-domain edits.** `afftfilt` with expressions over `bin` and `re`/`im`. Use it
   for spectral gates (zero bins below a threshold), spectral freeze, bin-index
   quantization (keep only bins on a harmonic series: Barbieri's harmonic-oscillator
   logic) and comb-spectrum masks from Xenakis sieves on bin index.

### B. Structural generators (control layer, all expressible as `mod()` arithmetic)

- **Coprime-length rows (Barbieri gate × pitch, Autechre counters).** Pitch row length
  7, gate row length 5, octave row length 3. Period = LCM = 105 steps. Form is
  emergent and fully deterministic.
- **Xenakis sieves for rhythm and pitch.** Unions and intersections of residue classes
  as boolean `aevalsrc` expressions.
- **Tendency masks (Tenney, Koenig, Truax).** Two piecewise-linear curves bound each
  parameter, and events sample uniformly between them. This is the entire score.
- **Random walk with mirrors (GENDYN; Barker's "stochastic drift").** One primitive
  serves waveform breakpoints (timbre), onset jitter (groove), pitch (Brownian
  melody) and filter cutoff (texture). Second-order walks give smoother "drift".
- **Ergodic sections (Tenney).** Stationary distributions with no development,
  separated by abrupt state changes or very long crossfades.
- **Permutation stepping (Fell syllables, Malone chords).** Steinhaus–Johnson–Trotter
  ordering, so each bar differs from the last by one adjacent swap.
- **Density caps and rejection rules (Fell's "three events per grid").** Generate
  randomly, then reject by constraint.
- **Multistable meters (Fell).** Interpolate the IOI ratio between two meters and
  linger at the ambiguous midpoint.

### C. Perceptual targets (illusion as composition)

- **Endless rise and fall.** Shepard–Risset glissando, and Risset rhythm
  (endless accelerando). Evol's endless Hoover, Senni's endless build-up.
- **Beating and roughness.** Two sines at Δf = 0.1–10 Hz (Radigue, Lucier,
  Davachi). Δf of 15–40 Hz gives roughness.
- **Phantom tones in the ear.** Primaries f1, f2 at ratio about 1.2 → 2f1 − f2
  (Amacher). Write melodies the speakers never play. Needs speakers, not
  headphones; warn about level.
- **Fusion thresholds.** Click rate crossing about 20 Hz (rhythm → pitch); arpeggio
  rate crossing about 12 Hz (melody → chord, Barbieri); grain length below about 50 ms
  (event → timbre, Roads); interaural delay crossing about 1 ms → 30 ms (image → echo,
  Hecker).
- **Auditory chimera.** Envelope of A on the fine structure of B, with the number of
  filterbank bands as a slider between "speech" and "pitch" (Hecker).
- **Threshold tones.** 18 kHz and 25 Hz sines, felt or barely heard, noticed when they
  stop (Ikeda).

### D. A possible "ffmpeg-only" aesthetic (constraints as manifesto)

1. **One expression per piece.** As Hecker puts it: no mixing. Ideally the whole piece
   is one `aevalsrc` expression or one filtergraph string, and the score is the
   command line.
2. **Test signals only.** Ikeda's sine, noise, impulse, sweep and silence: an
   ffmpeg-native palette, since these are exactly what its sources generate.
3. **Iteration count as duration.** Lucier and Radigue forms: piece = passes
   0..K concatenated, where each pass applies the same filter.
4. **Data as score.** Any file read as PCM or bitstream; the filename is the
   composition.
5. **Determinism and seeds.** Every piece reproducible from (command, seed), with
   Autechre-style rule edits re-rendered.
6. **Genre forms as residue (Evol, Senni, Fell).** Take a club gesture (Hoover, supersaw
   stab, build-up, house chord), isolate it, and subject it to one continuous
   transformation, with the drop and the kick removed.

### E. Ten concrete first pieces (each one graph or one loop)

1. **Endless Hoover:** Shepard–Risset applied to a 3-saw detuned voice; r = −0.08
   oct/s; 10 min.
2. **Coprime arp:** Barbieri rows (7 pitches of the harmonic series × gate of 5 ×
   octave of 3) at 14 notes/s, through `aecho` taps at 3/4 and 5/4 steps.
3. **GENDYN-lite:** N = 4 breakpoints with mirrored Cauchy walks in `aevalsrc` state
   variables, or piped from a 40-line generator. Narrow-to-wide duration bounds over
   8 minutes.
4. **Room x32:** a spoken sentence, `afir` with a small-room IR, normalised, 32
   passes, concatenated.
5. **Ear melody:** f1 sweeping 2000–3000 Hz in a scale; f2 = 1.2·f1; the phantom tone
   2f1 − f2 carries the melody. Speakers only.
6. **Barcode:** the bytes of a PDF read as bits on a 1 ms grid; 1 = full-scale click,
   0 = silence; a 17 kHz sine floor that cuts at the end.
7. **Pulsar sweep:** pulsar train with f0 from 1 Hz to 400 Hz and a formant from 200 Hz
   to 4 kHz, with a sieve mask on the pulse index.
8. **For Ann variant:** 12 overlapping 8-octave rising glides, with entry spacing slowly
   modulated so the vertical intervals breathe.
9. **Radigue crossfades:** five two-sine beating states (Δf of 0.2–3 Hz), each 6 min,
   with 3 min `acrossfade` qsin transitions.
10. **CD-skip song:** a 50 s source budget; 588-sample-multiple loops chosen so that
    sr/L forms a pentatonic scale; hard discontinuities kept.

### F. Open verification items

- Evol and Shepard/Risset/rolls: I found no primary text. If it matters, check the
  MACBA Son[i]a #209 podcast and Roc Jiménez de Cisneros' own texts.
- Barbieri ratcheting: not found. The ER-101 operations (arithmetic, geometric,
  random, jitter) are confirmed.
- Hecker and Tenney: not found in the interviews I read.
- *For Ann (rising)* entry interval and glide parameters: verify against Polansky or
  Tenney's notes before quoting numbers.
- ffmpeg `aevalsrc` `st()`/`ld()`: **verified** to persist across samples in the local
  build (`st(0,ld(0)+1)/48000` ramps to 0.01 after 480 samples). So phase
  accumulators and random walks work inside one expression. The variable count is
  still limited (10 slots in the classic API), which caps in-expression GENDYN at a
  few breakpoints.
