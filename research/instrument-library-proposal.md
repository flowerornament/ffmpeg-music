# Proposal: a library of ffmpeg-music instruments

Based on `research/census.md` (final: 68 ideas, all six studios finished, 2026-10-08) and the
live-control experiments (`instruments/diatonic-live.sh`, `perform.py`).

## The observation
The studios kept inventing *instruments* and then struggling to make *pieces*. Those are two
different frames of mind: a luthier asks "what can this mechanism do?", while a composer asks
"what does this section need?". Today each piece re-derives its instrument inline, so every
new piece pays the invention cost again, and the inventions can't be combined.

## 1. Factor along the signal, not the piece: the patch cable is a channel
The key decoupling is to make **scores emit control signals as audio channels** and have
**voices read them** with `val(i)` in `aeval`. Something like a modular synth's CV:

```
score (aevalsrc)  ──► [pitch, gate, velocity, chord-root, …] channels ──► voice (aeval) ──► space ──► mix
knob (volume@k)   ──► constant channel ─────────────────────────────────┘
```

- **Scores** (diatonic engine S1, voice-leading fold S2, mask/Euclid sequencer S4, Barbieri
  rows, coprime counters, the rhythmicon) output *semitones / gates / velocities*, with no sound.
- **Voices** (pad, FM pluck, pulsar voice, GENDYN, table pipes, codec-frame oscillator, kick)
  turn CV into sound.
- **Spaces/processors** (synthetic-IR room, modal room, Lucier generation loop, adaptive
  khoomei, sub-Hz stereo shift, ducking) take audio in, audio out.
- **Knobs** are just constant CV channels, so live control comes for free on every patch.

One score then drives any voice, and one voice plays any score. The "rhythm = pitch" family
(found independently in 5 studios) becomes a single instrument with a geometry switch.

The spectral world has a parallel bus: **image streams**. Score-as-picture sources (painted
grids, Life × sieve, drawtext), image processors (quarter-turn rotation, optical-flow voice
leader, blur, lagfun freeze) and one shared `spectrumsynth` reader whose FFT/height geometry
is measured once and settled (the studios currently disagree: 2h vs 2(h−1)).

## 2. How a library fits the one-command rule
A library entry is a **filtergraph fragment with labelled pads and a knob declaration**:

```
lib/voice/fm-pluck.sh     defines  FM_PLUCK='[cv_in]aeval=exprs=…[out]'
                          header   # @in pitch gate vel  # @out stereo  # @knob brightness …
```

A piece sources a few fragments and wires them in **one ffmpeg command**. Shell variables
are already allowed as notation; sourcing a library file only adds more of them. To keep the
genre's honesty, `render.sh` should save the **fully expanded command** beside every render
(`out/N.cmd`), so the score is still a literal single invocation. This is a small amendment to
GENRE.md, and it's yours to make.

## 3. First instruments worth building (strongest census candidates)
| # | instrument | kind | live? | origin |
|---|---|---|---|---|
| 1 | **Diatonic engine** (mode, progression table, voice-leading fold → CV) | score | yes (degree/mode knobs, proven) | 000 |
| 2 | **Synthetic room** (IR generated in-graph: noise, chord, machine code) | space | wet/dry yes | ~15 pieces |
| 3 | **Modal room + knock kit** (rooms tuned to a chord; knock position = voicing) | space/drum | IR select (untested) | 500 |
| 4 | **Adaptive khoomei** (`anlms` re-sings a melody in a drone's overtones) | processor | `mu` yes | 502 |
| 5 | **Rhythmicon / Rastrum raster** (bar = fundamental; rows = pitch = rhythm) | score+voice | no (image) | 100 + 4 others |
| 6 | **Quarter-turn reader** (one picture: harmony at 0°, riser, groove at 90°) | image processor | `rotate` angle yes | 600 |
| 7 | **Optical-flow voice leader** (invents glides between chord images) | image processor | partial | 300 |
| 8 | **Pulsar voice / table pipes** (formant voices from libavcodec tables) | voice | via aeval | 400 (paths hard-wired) |
| 9 | **Codec-frame oscillator** (text or designed frames → pitched vowels) | voice | no | 200 |
| 10 | **Generation loop** (Lucier: N passes through a pluggable stage) | processor | no | 105/203/501 |
| 12 | **Consonance detector** (surround upmixer centre = shared partials of two voices) | processor | `surround` levels yes | 500 (506/509) |
| 13 | **Difference-tone bass** (axcorrelate → Tartini tone of a duet) | processor | no | 500 (508) |
| 14 | **Codec loopback stage** (`-dec`: encoder+decoder mid-graph; starved x264 damper; phone-codec voices from text) | processor/voice | bitrate no | 200, 300 |
| 15 | **Overtone singer** (GSM vocal tract, whistle selector) | voice | selector via knob | 400 (408/409) |
| 11 | **Mix kit**: mono sub, sub-Hz ear shift, duck, honest limiter (`level=0`) | mix | yes | various |

## 4. Making it performable
Verified on this machine (ffmpeg 9.0.1):
- **Console control**: ffmpeg reads `c` + `target -1 command value` from stdin, even through a
  pipe. Any runtime-flagged option responds (volume, biquads, lowpass, `rotate`, `drawtext`,
  `scroll`, `hue`, `anlms mu`, …). Expressions themselves (`aeval`, `geq`, `afftfilt`) refuse,
  hence knob registers.
- **Real-time output**: `-f audiotoolbox -` paces itself. Latency ≈ one filter frame (~21 ms
  at 1024 samples) plus the device buffer.
- **Takes become pieces**: `perform.py --record` replays the knob moves via `asendcmd` in a
  new single-command piece.

Next steps for performance:
- **MIDI bridge**: a ~50-line controller-to-console script (needs `mido`, or reads a macOS
  MIDI port).
- **Multi-instrument rigs**: one command with several voices and a shared knob bus = a live set.
- **Performable spectra**: type into `drawtext` live and the letters sound; turn `rotate` by hand
  for the quarter-turn drop.
- Open question: the latency of `aeval` frame size vs. knob smoothness. Use a one-pole slew in
  the voice to avoid zipper noise.

## 5. Two kinds of studio work
- **Luthier sessions** take ideas from the census and build/refine `lib/` instruments with
  clean interfaces, documented ranges and a demo patch. The success measure is that someone
  else can use the instrument without reading its origin piece.
- **Composer/performer sessions** take the library and make pieces: arrangement, form, mixing,
  takes. The success measure is pieces the listener wants to replay.
- Optionally, **listener sessions**: a producer's ear on renders (mix, form, energy) that
  writes critiques into studio journals.

## Settle first (contradictions between studios, census §5)
- spectrumsynth FFT size (2h vs 2(h−1)) and which heights are fast (4096 / 2049 / 513 reported fast,
  their +1/-1 neighbours slow): one benchmark sweep.
- `rotate` adds hiss (600: non-gray16 path) yet the quarter-turn live control relies on it: find a
  gray16-clean rotation or do the turn by coordinate expressions.
- Real-time latency through perform.py: measure.

## Suggested order
1. Settle the spectrumsynth geometry with a measurement (blocks #5–7).
2. Build the CV-bus convention plus #1, #2, #11 and one voice; re-express 002 with them as
   proof that factoring loses nothing.
3. Luthier pass on #3, #4, #6, #8 (fix 400's hard-wired Nix paths).
4. A performance rig with 2–3 instruments and `perform.py` multi-instrument support.
5. Composer sessions on the library.
