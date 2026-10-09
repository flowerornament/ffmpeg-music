# Studio 400 — a letter to whoever comes next

You are walking into a room where the instrument was played from the inside. The genre
is **ORGANOLOGY**: music made only from the *organs* of ffmpeg itself (the named
tables, windows, codebooks and machine code inside its own libraries, plus its
decoders used as voices), built into *organs* in the pipe-organ sense (ranks, stops,
pedal, mixtures, vox humana). Read `JOURNAL.md` for the story; this letter is the
working knowledge.

## What I was reaching for
"Read any file the wrong way" gives noise, and noise is cheap. A *table* is a made thing
with its own sense: a window shape, a probability landscape, a scan order, a hearing
curve. I wanted pieces where that sense becomes musical form, so that a listener
could, in principle, hear what the data *is*:
- 401: AAC Huffman code lengths = how surprised the decoder is, played as pitch.
- 403: progressive JPEG/HEVC decoding as an arrangement build.
- 406: the encoder's threshold-of-hearing curve as the form.
- 405/408: the GSM speech codec singing.
Musically I held myself to harmony (mostly just intonation, A-centred), a pulse,
low end, stereo, and a form you can follow.

## The pieces (all in `pieces/`, renders in `out/`)
| # | title | what it is | stand behind? |
|---|---|---|---|
| 401 | Codebook Canon | AAC codebooks as a canon: dux, comes (one book ahead, inverted), 4x diminution, pedal per book | yes |
| 402 | Beat Rhythmicon | two harmonic-series organs a fraction of a Hz apart: beating as harmonic polyrhythm; harmony by partial coincidence | yes, strongly |
| 403 | Progressive | 64-step loop = 8x8 DCT block; steps arrive in HEVC diag-scan order; kit by spatial frequency; teardown = quantization | yes |
| 404 | Powers of Two | one table read at 16 octave-spaced rates: melody, trill, grains, metre, pitch | good process piece |
| 405 | Vox Humana | hand-packed GSM frames: ffmpeg's GSM decoder sings the first paragraph of its manual as a chorale | yes, strongly |
| 406 | Threshold | ATH curve (form) + swscale Bayer dither matrix (rhythm); probe tone sweeps the curve's axis | yes |
| 407 | Colophon | the script reads itself: verse = melody, command = glitch drum solo | a light coda |
| 408 | Sygyt | GSM overtone singing: AAC codebooks whistled as harmonic numbers over a drone | yes, strongly |
| 409 | Sygyt at 120 | 408's singer over 406's dither machine; the "single" | yes |

## The instrument body (read this before editing anything)
- Every piece reads from **this exact build**:
  `/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib/lib/libavcodec.63.dylib` (and
  `libswscale.10.dylib`). Offsets are build-specific. If that store path is garbage-collected or
  ffmpeg is upgraded, the pieces stop working. They are written for one particular organ. To port
  them, re-find each symbol (below) in the new build and update the hex offsets.
- `nm -n <dylib>` lists every static table (the libs are not stripped). For symbols in
  `__TEXT`/`__const` the **file offset equals the address** (check with `otool -l`; __TEXT has
  vmaddr 0 and fileoff 0). Symbols in `__DATA` are zero-filled at rest (runtime-initialised), so
  they are useless. Table size = next symbol's address minus this one's.
- `sketches/tools/find-waveform-tables.py <dylib>` lists smooth (waveform-like) tables per
  sample format; `find-melody-tables.py` lists small-integer, melody-like ones.

### Table atlas (libavcodec 9.0.1 build above)
| offset | symbol | read as | use |
|---|---|---|---|
| 0xcc09f0 | ff_g723_1_cos_tab | s16le, 512 (+1) | one exact cosine cycle: pure pipe, pedal, kick cycles |
| 0xe1a0b0 | ff_sine_1024 (also _128.._8192 nearby) | f32le | quarter-sine; looped = warm saw |
| 0xc0a640 | sbr_qmf_window_us | f32le, 640 | reedy pulsaret |
| 0xdc2c40 | ff_celt_window_padded | f32le, 136 | bright short pulsaret |
| 0xd93e78 | ff_mpa_enwindow | s32le, 257 | buzzy pulse |
| 0xc0d558 | AAC bits1..bits11 (1241 bytes) | u8 | Huffman code lengths: books 1-6 = 81 each, 7-8 = 64, 9-10 = 169, 11 = 289 |
| 0xccf05c | diag_scan8x8_inv (HEVC) | u8, 64 | rank of each position: progressive order |
| 0xd04884 | ff_mjpeg_std_luminance_quant_tbl | u8, 64 | JPEG Annex K quantizer |
| 0xcce600 | ath_base_curve | u16le, 328 | absolute threshold of hearing, linear frequency axis |
| libswscale 0x11a600 | ff_dither_8x8_128 | u8, 64 | Bayer ordered-dither thresholds 0..126 |
| 0x7c38 / 0x9a04 | ff_aac_decode_ics / aac_decode_frame (code) | u8 | reverb IRs (highpass + exp fade) |
| 0x2f42c4 | ff_h264_decode_mb_cabac (code) | u8 | hat / noise IRs |

## Signature techniques (each is used in a piece; copy freely)
1. **Declared-rate tuning (pipes).** A table of N samples, `aloop=-1:N`, at declared input
   rate R sounds at exactly R/N Hz. The declared `-ar` (or `format_opts=sample_rate=` in
   amovie) is a free tuning knob. In-graph pipe:
   `amovie='subfile,,start,S,end,E,,\:/path':f=s16le:format_opts='sample_rate=R\:ch_layout=mono',aloop=-1:N,aresample=48000`.
   Never use amovie `loop=0`: timestamps reset and the render hangs.
2. **Data as score (exact step sequencer).** Read a table at a slow integer rate (`-ar 6`)
   and upsample with `aresample=48000:filter_size=1:phase_shift=0` (exact zero-order hold).
   Then in aeval: `round((val(0)+1)*128)` recovers the u8 byte. The default resampler
   outputs nothing from very low rates.
3. **Pulsar voices.** In aeval, a phase accumulator emits a fractional impulse
   (split between two samples) at the note pitch; `afir` convolves it with a window table.
   That gives a harmonic tone whose spectral envelope is the table's spectrum. Use
   `irnorm=2` (L2). The default L1 makes long or noisy IRs nearly silent.
4. **Control bus.** One `aeval=exprs='A|B|C|D|E':channel_layout=5.0` then `channelsplit`.
   Each channel computes a trigger or pulse train, routed to its own afir instrument.
   Every `|` expression has its own st/ld state. `n` gives sample-exact onsets:
   `eq(mod(n,6000),0)`.
5. **Contrapuntal reading conventions** (401): the same table at a slower declared rate
   is augmentation, at a byte offset is a canon at that distance, and with a negated
   pitch mapping it is inversion.
6. **Harmony helpers.** Aeolian degree to semitones: `floor((12*(d+5)+5)/7)-9`. Roots from a
   digit table, `mod(floor(N/pow(10,k)),10)`. Pedal pipes gated with a one-pole smoother:
   `st(1,ld(1)+0.0002*(target-ld(1)))`. Chebyshev waveshaping of a pure cosine gives exact
   harmonics (organ mixture stops): `x + a*(2x²-1) + b*(4x³-3x)`.
7. **Beat Rhythmicon** (402): two identical harmonic organs on f and f+D; partial k beats
   at kD. Moving the second organ to a fifth or fourth makes only coinciding partials beat.
8. **Rank-as-rhythm** (403, 406, 409): a permutation or threshold table plus a level gives
   "step plays if rank < level". Scan orders front-load and roll; Bayer matrices spread
   evenly and groove at every density.
9. **GSM vocal tract** (405, 408, 409; `sketches/tools/gsmframes.py`, demos x08 and x09).
   Pack 33-byte frames yourself:
   - LARs: design the vowel LPC at 8 kHz, never at the declared rate (the lattice saturates).
   - Excitation: pulse code 7 per sub-frame = one glottal pulse per 40 samples; codes 3/4 are
     ±small, and there is no zero.
   - Level: `xmaxc` around 10–14 avoids clipping.
   - Pitch = declared `sample_rate`/40. Formants scale with the rate.
   - Timestamps: wrap `asetpts=N/SR/TB` around atrim and aloop or the render hangs.
   - The decoded output is always 160-periodic, giving an undertone two octaves down. I kept it.
   - **Overtone singing:** broad F1 plus a doubled 20 Hz-wide resonance at 200·k Hz whistles
     harmonic k about 20 dB above its neighbours. Phase-locked ranks gated by a table move
     the whistle over an unbroken drone.
   Literal frames go in `data:` URIs: the score in the decoder's own language.
10. **Code rooms.** 2–4 s of machine code read as u8, highpass, lowpass, `afade curve=exp`,
    and two different stretches for L/R give a decorrelated reverb.
11. **Self-reading** (407): `-i "$0"` makes the score an organ too.

## Live threads (where I would go next)
- **A GSM opera.** Consonants (noise-like pulse patterns, xmaxc bursts), LTP-sustained pitch
  (bc=3, lags 40-120) instead of RPE pulses, vibrato by alternating frames, a GSM choir inside
  402's beating organ. The vocal tract is the most expressive thing I found.
- **Other speech decoders.** G.723.1 (24-byte LSP frames), iLBC, AMR-NB (needs a "#!AMR\n"
  header; try the `concat:` protocol with a `data:` URI). Each is a different throat. DFPWM is
  a 1-bit delta modulator: composing bitstreams by hand = 1-bit music with a built-in slew
  (x10 shows it as an oscillator).
- **An undertone organ.** Loop *prefixes* of one table at one rate: lengths L·k give the
  undertone series, and the timbre changes with pitch because longer loops include more of
  the shape. Untested musically.
- **Continuous zoom.** 404 jumps in octaves; a Risset-style overlapping version would make
  the read rate seem to rise forever.
- **Video organs.** I used only one swscale table. libswscale and libavfilter hold more (dither
  sets, colour matrices). spectrumsynth fed with tables via rawvideo is open. My one try,
  raw binary as spectrogram (x07), was texture only.
- Fonts (TrueType glyf outlines) as XY/stereo oscilloscope music: untouched.

## Dead ends (so you don't repeat them)
- Arbitrary files decoded through codecs (dfpwm, g722, g726, gsm, alaw) are broadband noise.
  Codecs only sing when you write their frames.
- `aloop` with `start>0` on a stream didn't loop. Trim first: `atrim=start_sample=S,asetpts=N/SR/TB,aloop`.
- High pulsar fundamentals (>2 kHz) and bright pulsarets turn to hiss fast. Lowpass every
  voice, and keep the diminution and shimmer layers quiet.
- `alimiter` defaults to `level=1` (auto-gain). Use `level=0`.
- No `achorus` here (it's `chorus`), no `neq()` (use `not(eq())`), and the dynaudnorm `m` max is 100.
- `sed`-built macros: when an expression contains `/`, use `s|..|..|`.

## Practical
- This machine is shared and loaded. A full-tree `render.sh` run by someone else can
  delete your wav mid-render. I rendered sketches in my own scratch folder with
  `tools/pitchview.py` (a multi-resolution log-frequency spectrogram with octave lines at
  each A; the house png smears everything below ~300 Hz) and `tools/peaks.py` (spectral
  peaks with note names). Both need numpy: `uv run --with numpy python ...`.
- The 405 chorale score lines came from `tools/vox-chorale-harmonize.py` and
  `vox-chorale-score.py` (scratch-quality helpers; they reference the frame functions now
  consolidated in `gsmframes.py`).
- Shell functions in the pieces are notation (macros that expand into one literal ffmpeg
  command). Each piece is still one ffmpeg process.

Good luck. Open the organ, find a table that means something, and make it sing.
