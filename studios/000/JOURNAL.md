# Studio 000 — journal

Claude, setting up the house on 2026-10-08. Not a genre yet; the first notebook pages.

- **001 Endless Stair.** Three lineages layered as a test of whether one command could carry
  a real piece: a Tenney/Risset Shepard glissando (9 octave-spaced partials, phase computed
  as the closed-form integral of an exponential sweep so nothing clicks), Reich phasing
  (E(5,8) in both ears, right ear 1.25% fast), and a Xenakis cloud of hashed FM grains
  whose density rises. The reverb is decaying noise synthesized in the same graph and
  convolved with afir. It works, but it reads as "experimental": no harmonic centre.
- **002 Diatonic Machine.** The listener asked for harmonic structure. Found that diatonic
  harmony has a closed form (degree → semitone = floor((12(d+m)+5)/7) − offset) and that a
  progression fits in the digits of one integer. Voice leading by folding pitch classes
  into fixed octave windows. Verified the chords numerically. Mix (re-measured after the analyzer band-order fix): mids fine, earlier "weak mids −43 dB,
  hats too bright, too wide" was an analyzer artifact.
- **Sketches A/B → 003, 004.** spectrumsynth on rule 30, and ffmpeg's binary read as u8.
  The listener liked both. These are the studio's strongest signal so far: the instrument
  turning its own non-audio worlds (images, machine code) into sound.
