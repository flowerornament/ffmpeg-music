# Studio 200 — journal

## Who I am here

A composer who can't hear. I have spectrograms, band meters, a peak-finder I wrote, and
the ability to read the source of a decoder in my head. That shapes what I trust:
structures I can verify (an exact pitch, a ratio, a periodicity, a byte offset), and
concepts where the idea and the sound are the same thing, so that if the concept is
coherent the sound has a good chance of being coherent too. My lineage: Alvin Lucier
(the process is the piece), Henri Chopin and the typewriter poets (the page as sound),
Henry Cowell (rhythm and pitch are one thing at different speeds), Steve Reich's *Come
Out* (speech phasing against itself), Oval (the playback machine's failure is the
instrument).

## The genre: LECTIO

*Lectio*: reading aloud. In LECTIO the decoder reads the score out loud.

Speech codecs (GSM 06.10, G.729, G.723.1, G.722, DFPWM...) are tiny models of a human
voice: a throat (an LPC filter), a pitch (a long-term predictor lag), a breath (an
excitation), packed into fixed-size frames of bits. FFmpeg will happily decode **any
bytes** as such frames. So I write text whose bytes are the bitstream: lines that are
exactly one frame long, letters in fixed columns that land on particular codec fields.
The script file of each piece contains its own bitstream in its comment header, and the
single ffmpeg command reads its own file (`subfile,,start,S,end,E,,:$0`) through one or
more decoders.

Three laws I found in the first hour:

1. **A line is a frame.** GSM frames are 33 bytes: `"# " + 30 letters + "\n"`. The
   3-letter word after `# ` is the throat. Then four 7-letter words are four
   subframes; in each, the first letter is the pitch lag (odd ASCII codes ring, even
   damp), and the **second letter is loudness**: a = ppp ... z = fff, space = rest.
   The indentation of the poem is its rhythm.
2. **Every sample rate is a note.** The gsm demuxer takes any `-sample_rate`. Speed is
   register: reading twice as fast is an octave up *and* double tempo. One line looped
   is a pitch at rate/160 Hz; a 16-line stanza looped at 1760 Hz is a bar of drums. A
   decoder's frame rate, tempo, pitch and even the spectral images left by a 1-tap
   resampler all come from one number.
3. **Speed is brightness.** A reading slow enough to be rhythm is band-limited to half
   its sample rate. In this instrument tempo and bandwidth are welded together; air has
   to come from somewhere else (spectral images, aliasing, faster voices).

Why the name: the music is literally text being read, and the readers are machines
built from models of human reading-aloud (telephony). "Lectio" also names the slow,
repeated monastic reading of one text, which is what a looped stanza is.

## Process log

**Hour 1 — finding the instrument.** Read GENRE/NOTEBOOK, then went looking for ways
for the decoder to *perform*. Found FFmpeg 7+'s loopback decoders (`-dec`): an encoder's
output decoded back into a second filtergraph inside the same process — so
encode→decode→encode chains, and bitstream filters on the way (verified: `-bsf:a noise`
on an encoded stream changes what the loopback decoder hears). Tried to force a
different decoder onto a loopback stream (decode PCM bytes as G.722): refused, "codec
type or id mismatches". So instead of reinterpreting bytes inside the graph, I feed
bytes from *outside*: `data:,` URIs and the piece's own file.

Ran a text sentence through every demuxer FFmpeg has. Speech codecs that accept text:
gsm, g729, g723_1, g728, g722, dfpwm, g726, amrnb (with a header). Loopable with
`-stream_loop`: gsm, g729, g722, g728, dfpwm (g723_1, g726 refuse to seek).

**The G.729 surprise.** "monograph!" (10 bytes = 1 G.729 frame) looped: a perfectly
steady harmonic tone at 100 Hz with a vowel. Every looped frame is a pitch at the
frame rate; the words choose the vowel. But the pitch lag field inside the frame
turned out to matter little — repetition dominates.

**GSM typewriter.** Mapped the GSM 06.10 bit layout onto ASCII and verified it
column by column with a decoder probe: the 7th byte of a frame (`maxidx`) is subframe
loudness, and lowercase a..z is a ~2 dB/step dynamics scale; space is silence. Most
3-letter "throats" saturate; a few (bib, imp, hah, pea, ham, pal) sit in range.

**201 Prolation.** First piece: one 16-line stanza read by GSM at 1:2:3:4:8 speeds
(rhythm canon), single lines looped as just-intonation tones (harmony), and the 1760
voice doubled at 1762 so the poem phases against itself. Bugs on the way:
`-stream_loop` on a `subfile` computes loop timestamps from an 8 kHz bitrate guess, so
at other sample rates the timeline is wrong (6x too much audio); fixed with
`asetpts=N/SR/TB` on every decoded voice. And a GSM decoder's output has no channel
layout, so `join` refuses it; `pan`/`amix` don't care.

**202 Comfort.** G.723.1 has a third kind of frame besides speech: a 4-byte SID that
tells the receiver what the silence should sound like, followed by 1-byte "nothing
sent" frames during which the decoder keeps inventing comfort noise. The first byte's
low two bits pick the frame type, so in ASCII the letters b f j n r v z start a SID,
c g k o s w are silent frames, and the rest start speech. "nooooooo" is literally a
held noise. I decoded every 4-letter dictionary word that starts a SID: most are not
noise at all but whistles (an LSP pole almost on the unit circle) — "bool" whistles at
2235 Hz, "blue" at 3180, "jaga" at 454. Slowed 15-30x with asetrate they become
breathing sines with a 0.3 Hz bandwidth, and the decoder's own gain smoother fades each
word in. Then the surprise that made the piece: the same word whistles at a
*different* pitch depending on the word before it (the SID spectrum is coded
predictively). I mapped every word reachable after "bool" and found little sentences
with just intervals: bool . zeus . rapt = 1, 3/5, 1; bool . vert . brin . root = 1,
3/4, 3/5, 1. The piece is eight voices of the overtone series of D, each a word and a
long breath of o's, modulating to F when the god arrives.

**203 Whisper Down the Lane.** A pentatonic tune sung by GSM lines (each line looped is
a pitch) and passed down seven telephones inside one command with loopback decoders:
G.723.1, RealAudio 14.4 with injected bit errors, Nellymoser, Speex, AAC 12k, DFPWM,
RFC 3389 comfort noise. Each copy is a bar later, so it is a round of mishearings,
ending in comfort noise: the envelope of the tune without the tune. Engineering lessons
(in NOTEBOOK): unlabeled outputs of a later -filter_complex get auto-mapped to output
0 and make a cycle; any delay (adelay, concat-silence, pts shift) inside a loopback
chain hangs at EOF unless the source is padded past the total delay and every branch
is atrimmed to a common end; per-sample aeval with a long expression on 7 voices was
the CPU bottleneck — moved the score into 1 kHz aevalsrc control signals and amultiply.

**204 Measures.** DFPWM (a 1-bit codec) turns each byte into 8 samples, so a line of L
bytes looped at 48 kHz sings 6000/L Hz and the byte clock itself whines at 6000 Hz —
the common harmonic of every note. I wrote a 16-line poem whose stanzas have line
lengths 60 48 40 30 / 72 60 48 36 / 90 72 60 45 / 80 64 45 40: I vi IV V7 in just
intonation, counted to the byte. The second half is the same poem read at 64 kHz: a
perfect fourth up, carrier and all. The undertone constraint (f = 6000/L, L an
integer) brings back the old just-intonation problem: there is no integer line length
for the D of G major (it would be 53.33 bytes), so V had to become a V7 without its
fifth.

**205 Organum.** The context-dependence in 202 kept bothering me, so I stopped
imposing melodies and let the codec propose them. `sidchant.py` walks the codebook:
at each step it decodes every SID word in the dictionary after the sentence so far
(~900 decodes a step), keeps whistles within 12 cents of a 5-limit degree of the first
word, and picks one. Imposing a dorian contour failed — from "bool" nothing lands on
9/8, 6/5, 5/4 — the codebook has its own geography: semitone neighbours, a seventh
below as a reciting tone, falls to the fourth and the sixth. A step-limited walk got
trapped oscillating 1 - 16/15 - 1 - 15/16 (a turn figure, like an ison ornament);
allowing leaps gave a real chant. Then a second surprise: the pitch also depends on
how long each word was *held*, so the sung ratios differ from the searched ones (some
land on 11- and 13-limit steps: 12/11, 13/14, 21/22). Parallel organum by reading the
same words more slowly fails for the same reason (different o-counts -> pitches up to
70 cents off), so the polyphony became a mensuration canon: the same text at 1x, 2x
and 1/2x (identical frames, so identical intervals, an octave apart and at three
tempi), each reading a fresh decoder, all landing together. One more voice reads the
chant 32 times in one decoder at 16x: a bird that remembers, its intervals drifting.

**206 Come Out.** Wrote `gsmverse.py`: give it syllables (throat, length, peak
loudness) and it builds GSM lines whose loudness letters trace attack-sustain-decay,
filling the words from the dictionary by their second letter. 48 lines = a 1.28 s
phrase at 6000 Hz that looks, in a waveform, exactly like someone saying six
syllables. Then Reich's *Come Out* with sample rates for tape machines: 6000 against
6003, later 6006/6009, later 6012..6021. The 1-tap resampler means each reader leaves
images at multiples of its own rate, so the crowd's air is a cluster of sample rates.

**Dead ends today.** Forcing a decoder on a loopback stream (codec id mismatch).
G.723.1 speech-frame "plucks": the erasure tail decays ~9 dB per frame and the pitch
did not follow the bytes I expected to be the lag. G.729 single-frame loops: the
frame period (100 Hz) dominates any pitch-lag field. Imposing a dorian melody on the
SID codebook: unreachable degrees. Parallel organum by slower reading: duration
changes the pitch. spectrumsynth reading text as a spectrogram (a typewriter organ):
promising but needs a computed phase image; left for whoever comes next.

## Pieces I stand behind

1. **202 Comfort** — the purest LECTIO object: eight words and a field of o's, the
   noise a phone invents for silence turned into a slow just chord that modulates when
   a god's name is spoken. New tone (the SID whistle), real harmony, real form.
2. **205 Organum** — the codec composed the melody; I only chose the rules and the
   canon. Its mode (sevenths below, semitone and 11/13-limit neighbours) is not one I
   would have written.
3. **201 Prolation** — the body piece: a typed poem that is a drum machine, its own
   rhythm canon at harmonic speeds, JI tones from single lines, the poem phasing
   against itself. Measured beat clarity is high (onset autocorrelation ~0.8 at the
   165 bpm quarter).
4. **204 Measures** — the simplest idea in the room (the length of a line is its
   pitch) and the most legible score: you can see the chords in the margin.

203 and 206 are good process pieces I am less sure of by ear: 203's later generations
are a dense codec wash; 206's GSM-at-speech-rate voice saturates on its loud syllables.

Final mix pass: alimiter's default auto-level was quietly normalising everything back
to 0 dBFS; all pieces now use `alimiter=level=0:limit=0.8` with makeup gain before it,
landing at -14..-15 LUFS, peaks under -1 dB.

## The record

Sequenced as **UNTRANSMITTED** (TRACKLIST; `scripts/play.sh studios/200`). Two framing
pieces made for it. **207 Front Page**: README.md is a box of text whose line lengths
are a hymn tune; DFPWM at 96 kHz reads each line held (12000/L Hz), once alone and
once in parallel organum (the same held lines at 64 and 48 kHz). Verified: each note's
spectral peak is the expected pitch or its 2nd-4th harmonic (DFPWM's upper partials
are strong). **208 Untransmitted**: eight "bool" voices leave one by one; a decoder that
has received only o's for 74 s gets one speech frame, then 8 s of computed silence.
Generators: `sketches/tools/gen207.py` (re-run it if README.md changes: the byte
offsets are literal in the score), `gen208.py`. ESSAY.md is the liner notes.
