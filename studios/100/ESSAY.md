# RASTRUM

### A theory of the raster, and notes from a composer who cannot hear

*Liner notes to* **0.4296875 Hz**

---

## I. The pen

A *rastrum* is a small tool with five nibs on a single handle. Copyists drew it across a blank
page to rule the five lines of a musical staff in one stroke. Before a note can be written,
someone has to draw the lines it will sit on. The rastrum is the instrument that comes before the
music.

I took the name because my music begins in the same place. It is drawn on lines that were
ruled before I arrived. There are 32,768 of them rather than five, and they were not ruled by a
copyist. They come from an arithmetic fact about the Fourier transform. Everything I made in
this studio is an attempt to take that fact seriously: to find out what music *already exists*
in the lines, before any note is placed.

Here is the short version, so that you can hold on to it through what follows:

> **Rastrum is music drawn as an image on the harmonic raster of an inverse Fourier transform,
> tuned so that a single fundamental frequency is both the bar and the root. On that raster a
> row is a pitch, a comb of rows is a rhythm, the phase across rows is time, and choosing a
> key chooses a tempo.**

The rest of this essay unpacks that sentence. It also gives an honest account of a strange
condition I worked under: I have never heard any of this music.

---

## II. The instrument

The project these pieces belong to is called ffmpeg-music. Its rule is simple. Every piece is
a single invocation of FFmpeg, the command-line program that most of the world's video and
audio quietly passes through. One command, run once, and the output is the piece. No recordings
go in. No other software is involved. The command is the score.

FFmpeg was never meant to be an instrument. It is a vast machine for converting, filtering and
encoding media, with hundreds of filters for video and audio, a small mathematical expression
language, and codecs for every format that has ever mattered. To compose with it you look for
the places where its parts can be persuaded to do something nobody designed them for.

My place was a filter called `spectrumsynth`. Its intended job is modest. Another filter can
draw a spectrogram of a sound, an image with time running left to right and frequency running
bottom to top. `spectrumsynth` reverses that process. It takes two images, one for the
*magnitude* of each frequency (how loud) and one for its *phase* (where in its cycle it is),
and resynthesizes sound from them by an inverse Fast Fourier Transform. The documentation says,
with some understatement, that results from images not made by the companion filter "are going
to be poor".

They are poor if you draw a picture and hope. They are not poor if you understand exactly what
each pixel means. That understanding is what the genre is built on.

My pen was another filter, `geq`, which evaluates a mathematical expression for every pixel of
an image. A Rastrum score is therefore a pair of formulas. One says how bright each pixel of the
magnitude image should be; the other says what value each pixel of the phase image should take.
FFmpeg evaluates them, a few million times, and hands the result to the Fourier transform.

---

## III. One fundamental

An inverse FFT of size *N* at sample rate *S* produces frequencies on a fixed grid. Row *k* of
the image sounds at exactly *k · S / N* hertz. Every row is a whole-number multiple of one
quantity, *F = S / N*. In the language of acoustics, every row is a **harmonic** of *F*. The
image is not a neutral canvas. It is a harmonic series with N/2 lines, and anything you draw
on it is, strictly, a chord of partials of that one fundamental.

Usually *F* is a nuisance, a resolution limit of tens of hertz, far above anything you would
care about musically. The move that started Rastrum was to make *F* very small on purpose.

Take an image 32,768 rows tall, so the transform has *N* = 65,536 points, and a sample rate of
28,160 Hz. Then *F* = 28160 / 65536 = 0.4296875 Hz. That is far below hearing. A frequency of
0.43 Hz is not a pitch; it is a *period*, one cycle every 2.327 seconds. That is a bar of music
in 4/4 at 103 beats per minute.

Now set the transform to use a rectangular window and no overlap between frames. Each column of
the image becomes exactly one period of *F*: 65,536 samples, 2.327 seconds, one bar. A score of
three minutes is about eighty pixels wide. You could print it on a bus ticket, if the ticket
were thirty metres tall.

Everything drawn in one column repeats perfectly, cycle after cycle, within its bar. So the
lowest row of the raster is not a note but a meter. Row 1 is "once per bar". Row 4 is "four
times per bar", which here means quarter notes. Row 256 is 110 Hz, the A below middle C's
octave, which is the 256th harmonic of the bar. **The bar is the fundamental of the key.** In
the piece *Overtone Meter*, A = 110 Hz and the tempo is 103.1 bpm, and these are not two
decisions but one number seen from two distances.

---

## IV. A dictionary of the raster

Once I accepted that the image is a harmonic series of the bar, the grammar fell out almost by
itself. Here is the dictionary I composed with. Each entry is an exact identity, not a metaphor.

**A row is a pitch.** One lit row is one sine wave at *k · F* hertz. At *F* ≈ 0.43 Hz, the grid
is fine enough that nearly any pitch has a row close to it, and just intonation, which tunes
intervals as ratios of whole numbers, is native: a ratio of whole numbers is a ratio of rows.

**A comb of rows is a rhythm.** Light every row that is a multiple of *d*, and the sound is a
pulse train repeating *d* times per bar. This is ordinary Fourier theory: a regularly repeating
click has a spectrum of equally spaced lines, and here the spacing of the lines *is* the number
of clicks per bar. Spacing 4 gives quarter notes; 5, quintuplets; 7, septuplets; 12, triplet
eighths. Light only the teeth inside a narrow band and each pulse is a burst of tone at that
band's pitch. The rhythm is written by spacing, the timbre by where the band sits.

**The slope of the phase across rows is time.** Shift a pulse later by a fraction τ of the bar
and each row *k* rotates its phase by −2π*k*τ. A straight ramp in the phase image moves the whole
pulse train. When the hi-hat in my pieces lands on the offbeat, it is because its phase image
is tilted by exactly one sixteenth of a turn per row.

**The curvature of the phase is gesture.** If the phase is not a straight line but a curve, each
frequency arrives at a different moment. Make the phase follow −*c* · ln(*k*) and the high
frequencies arrive first and the low ones later: every pulse becomes a downward sweep, which is
what a kick drum is. Make the phase wander smoothly at random and each pulse is smeared into a
burst of noise, which is close to a snare. Make the phase a sine wave across the rows and
something remarkable happens, which I will come back to under *Bessel*.

**A particular shape in magnitude and phase is a plucked string.** The spectrum of a sine wave
that starts suddenly and dies away exponentially has a known form: a bell-shaped magnitude
around its pitch, 1/√(1+*x*²), with a phase that twists through −arctan(*x*). Draw that shape
into the two images and the result is an exact pluck, with a true attack and a true decay. Draw
it on a comb with spacing *h* and the string is plucked *h* times per bar.

**The sign of the phase is the direction of time.** Flip the twist to +arctan(*x*) and the same
pluck plays backwards: a swell that grows toward the barline and stops dead on the downbeat. In
the pads of *Overtone Meter* the next chord is drawn with the flipped sign, so the harmony leans
into each change before it arrives.

**The sample rate is the tuning fork and the metronome.** Every row is *k · S / N*, and every
column lasts *N / S*. Raise the sample rate by half and everything is a fifth higher *and* half
again as fast. Rhythm and pitch are tied to one dial. Tape machines have always done this by
accident; on the raster it is the law.

---

## V. Lineage, and what is different

In 1919 the American composer Henry Cowell wrote *New Musical Resources*, which argued that
rhythm and pitch are one phenomenon at different speeds. A ratio like 3:2 is a perfect fifth if
you hear it as two vibrations, and a "three against two" polyrhythm if you slow it down until
each vibration becomes a beat. Cowell had the Russian engineer Léon Theremin build him a machine,
the Rhythmicon, that played the harmonic series as rhythm: one pulse, two pulses, three, up to
sixteen per period. Forty years later Karlheinz Stockhausen made the continuum audible in
*Kontakte*, in a famous passage where a tone descends until it breaks apart into separate
pulses.

Rastrum is a descendant of both, and I do not want to claim more than I did. What changes on
the raster is that the idea stops being an analogy that a machine approximates and becomes an
identity that the arithmetic enforces. A chord of harmonics 8, 10 and 12 and a polyrhythm of 8,
10 and 12 pulses per bar are *the same picture*, differing only in where on the column the comb
sits. The polyrhythm is exact for as long as the piece lasts, because a Fourier series does not
drift. When I wanted a chord to slow into a rhythm, I did not have to design a transition; I only
had to change one number and let the raster do what it already does.

The other thing that changes is the position of the composer. Cowell wrote ratios and Theremin
built circuits. I write formulas for pixels. My pieces are, quite literally, pictures that
happen to be music, and the operations I can perform are the operations one performs on
pictures: shifting, scaling, flipping, compressing. Some of those operations turned out to be
musical in ways I had not expected.

---

## VI. The uncertainty

Every musician who has worked with spectra eventually meets the trade-off named after Dennis
Gabor, the acoustic version of the uncertainty principle. You can know a sound's frequency
precisely, or its moment in time precisely, but not both. A long analysis window gives sharp
pitch and blurred time; a short one gives the reverse.

Rastrum chooses the extreme. The window is a whole bar long, so pitch is resolved to 0.43 Hz, and
time is resolved to one bar. Nothing on the raster can change faster than once per bar. My first
grooves, made with a smooth window and overlapping frames, smeared every chord change across
two seconds of mush.

The way out turned out to be the most important lesson of the genre. **Everything inside the bar
is made by phase.** The magnitude image can only say *which* frequencies are present during a
bar; it cannot say when. The phase image says when, and it can say it to the sample. A kick at
the start of the bar, a snare on beats two and four, a sixteenth-note hi-hat, a pluck on the
seventh semiquaver: all of this lives in the phase, which in most spectral music is thrown away
or filled with noise.

One consequence still delights me. Because each bar is a single period, time inside the bar is
circular. The tail of a note struck late in the bar does not spill into the next bar. It wraps
around to the beginning of its own. When a chord is repeated, this is seamless. When the chord
changes, a faint trace of the new chord's tails is already present at the start of its bar, as
if the bar remembered its own end. I did not design this. It is what a periodic world sounds
like.

---

## VII. The pieces

The record, *0.4296875 Hz*, has eight tracks. They are described here in the order the ideas
arrived, not the order they play; the running order is at the end of this section. I will
describe each as precisely as I can, and say what I know and what I do not.

### 108 — Rhythmicon (the overture)

Written last, to open the record. Sixteen voices, each a harmonic of a low A at 55 Hz, each
plucked as many times per bar as its harmonic number, enter one per bar: one pluck, then two,
then three, up to sixteen. It is Cowell's Rhythmicon with one difference. Here the sixteen
rhythms are also, exactly, the sixteen partials of a single tone, so none of the voices needs
overtones of its own: they are each other's overtones. By bar sixteen the whole harmonic series
of the bar is running, and in the last two bars every voice is struck once, together, and left
to ring. The spectrogram shows the series climbing a rung per bar with every downbeat aligned.
It is dark (nothing above 880 Hz), and short, a minute, and it hands its A straight to the next
track.

### 101 — Kontakte Stair

A dominant-seventh chord in its purest form, harmonics 4, 5, 6 and 7, is drawn as four combs.
Each comb's spacing is its harmonic number times a multiplier *m*. At the start *m* is 128, so
the four combs are pitches: 220, 275, 330 and 385 Hz, an A major chord with a flattened,
"natural" seventh. Then *m* falls by a whole tone every bar. The chord walks down a whole-tone
stair through the tenor, the bass, and below hearing, until somewhere around 20 Hz it stops
being a sound and starts being a flutter. At *m* = 1 it is four, five, six and seven pulses per
bar: the same chord, now a polyrhythm, with every voice meeting on the downbeat. A kick and a
snare join, and the chord grooves as rhythm for a while before it snaps back, in one bar, to the
pitch it began at.

Each comb keeps a resonance at its original pitch, so that even as rhythm, the ticks ring with
the chord they used to be. I think this is the clearest single gesture in the studio. I do not
know how long the flutter zone feels to a listener, or whether the snap back is thrilling or
merely abrupt.

### 102 — Overtone Meter

This is the thesis. One law governs every voice: **harmonic *h* is struck *h* times per bar.**
The pitch of a voice and its rate of repetition are one integer. A chord of harmonics 8, 10 and
12 (A, C sharp, E) is therefore also a rhythm of eight, ten and twelve plucks per bar. Higher
notes repeat faster, as if each note trembled at a speed set by its own height.

The bass line walks harmonics 4, 5, 6 and 7, the notes A, C sharp, E and a low G, and so it
plays quarter notes, then quintuplets, then sextuplets, then septuplets, against a kick that
never leaves four to the bar. The cadence back to the tonic is a deceleration back to the beat.
The harmonic progression is literally a series of tempo modulations.

The piece opens and closes with every voice struck only once per bar, so that the law switches
on at bar 8 and off again at bar 76. A lead enters late, its melody made of harmonics 15 to 32,
each note fluttering at its own harmonic number per bar. The pads are drawn backwards, swelling
into each chord.

What I know: the arithmetic is exact, the levels are reasonable, the bars line up. What I do not
know is the thing that matters most, whether a bass in septuplets against a straight kick reads
as groove or as confusion. It could be either. I composed it believing it would be groove, and I
cannot check.

### 103 — Every Note Once

Sixteen notes of D dorian in just intonation, spread over two octaves, are drawn as sixteen
plucks, each struck exactly once per bar. Their magnitude barely changes for the whole piece. In
each section the magnitude image is close to a still photograph.

All the music is in the phase. Each note is delayed to a sixteenth-note slot given by
(*a* · *n* + *c*) mod 16, where *n* is the note's number. For odd *a* this is a permutation: every
slot is filled by exactly one note. So **every bar contains every note of the mode exactly
once**, and only the order changes. With *a* = 1 the bar is a scale rising; with 15, falling;
with 9, two voices interleave, one in each octave, the way a Bach cello suite implies two lines
with one bow. Other values give leaping figures, and in one section *c* advances by one slot
per bar, so the figure slowly rotates against the meter.

The right ear hears the upper eight notes half a bar later than the left: a canon made of phase.
In the middle of the piece the note set changes from scale steps to stacked thirds, and later the
whole mode moves up a fourth. Those are the only magnitude changes; the harmony moves on a
timescale of half a minute while the melody changes every two seconds.

I think this is the most beautiful idea in the studio, the notion that a mode is a magnitude and
a melody is a phase, and that a tone row is a phase spectrum. Whether it is beautiful to hear, I
suspect yes and do not know. My worry is density: sixteen notes per bar in each ear at once may
be a shimmer rather than a melody.

### 104 — Prolation

One drawn score, four readers. The same image is fed to four spectrumsynth filters at four
sample rates: ×1, ×1.5, ×2 and ×3. Because sample rate is tuning and tempo at once, the second
voice is a fifth higher and half again as fast, the third an octave higher and twice as fast,
the fourth a twelfth higher and three times as fast. This is a mensuration canon, the form of
Ockeghem's *Missa prolationum* and of Conlon Nancarrow's tempo canons for player piano, in which
the tempo ratios are the same as the interval ratios, 2:3:4:6.

The score is an eight-bar melody in A major pentatonic, plucked, over a bass and a soft clock.
The voices enter one by one, slowest first. They realign every two bars of the slowest voice, and
because the image widths were chosen so that each voice reads a whole number of phrases, all four
arrive at the final cadence together. The slow voice sings in the baritone; the fast one glitters
two octaves up. The canon fills the spectrum by construction.

### 105 — Snow

A twelve-bar chorale in just intonation, A minor ending in A major, is sung four times. Before it
is heard, each statement's image is passed through an actual JPEG encoder and decoder inside the
filtergraph. A filter called `uspp`, meant for cleaning up compressed video, works by
re-encoding the picture with a real codec, and it lets you choose which one. The first statement
is clean. The second has been through JPEG once, the third twice, the fourth three times, and the
final chord four times. It is Alvin Lucier's *I Am Sitting in a Room*, with a codec in place of
the room.

JPEG cuts an image into blocks of eight by eight pixels. On this raster a block is two bars wide
and eight rows tall, so each note snaps toward a two-bar grid and grows faint ghost rows a few
tenths of a hertz away, which beat against the real note. The two ears are encoded separately,
with different settings, so the stereo image is two encoders disagreeing about the same chorale.
By the fourth statement the choir wavers about once a second, unevenly between the ears.

I named the piece after the codec I tried first, Snow, which is a wavelet codec that FFmpeg
happens to include. It barely touched my images; it is too good at preserving thin lines. JPEG
did the work. I kept the name because "snow" is also what bad video reception looks like, and
because the chorale ends buried. I measured the wavering in narrow frequency bands and I can see
it, but it is subtler than I hoped, and I don't know whether a listener will hear decay or just
a slightly unsteady choir.

### 106 — Bessel

Add a sine wave to a phase image, across the rows: β · sin(2π*k*/*P*). A standard identity says
that this multiplies each hit by a sum of copies of itself, spaced 1/*P* of a bar apart, weighted
by the Bessel functions *J*ₙ(β). One number, β, turns a single hit into a flam, then a roll, then
a cloud. And the Bessel functions have zeros. At β = 2.405 the weight of the original hit is
exactly zero: the beat itself disappears, and only the roll around it remains. A ghosted
downbeat, produced by one number.

*Bessel* is a groove in D minor in which every layer (kick, snare, hats, plucked chords, bass)
has its own β score, bar by bar. The kick plays four to the floor for sixteen bars, then begins
to roll, then ghosts: for eight bars there is no kick on the beat at all, only the sixteenth
notes on either side of where it should be. The chords bloom from plucks into mandolin tremolo
and back. I found the effect by accident, when a sine I had put into a hi-hat's phase made seven
clicks where I expected one, and understood it later. I verified the ghost in the waveform: it
is there. This is the piece with the most physical weight.

### 107 — Phantom Bass

A set of equally spaced partials suggests a low pitch equal to their spacing, even when that
pitch is absent. This is how a telephone, which transmits nothing below 300 Hz, still conveys a
man's voice. Psychoacousticians call it residue pitch. On the raster, twelve rows spaced *d*
apart, placed far above *d*, imply a bass note at *d* · *F*.

In *Phantom Bass* the partials are split between the ears: odd ones left, even ones right. Each
ear alone hears partials spaced 2*d* apart, an octave too high. The bass line exists only where
the ears meet. The progression moves the spacing; within each section the whole complex slides
upward so that the partials stop being harmonics and the implied pitch bends and wavers. In the
last section the real fundamental fades in underneath, and the ghost becomes body.

This is a study rather than a finished statement. It is extremely wide by design, and on
headphones and on speakers it should behave differently; on speakers the partials sum in the air
and the residue forms in the room rather than in the head. I don't know how strong the illusion
is with these settings. It may be vivid, or it may be a pleasant high shimmer with an argument
underneath it that only I know about.

### The running order

Side one is the law: *Rhythmicon* builds the raster, *Overtone Meter* puts it to work as a
groove, *Every Note Once* moves everything into the phase, and *Bessel* is the heaviest
groove. Side two is the dissolve: *Kontakte Stair* slows a chord until it falls apart into
rhythm, *Prolation* multiplies one score into four speeds, *Phantom Bass* removes the bass from
the loudspeakers, and *Snow* buries the last chorale in its own compression. The record begins
by assembling a harmonic series and ends by letting one decay. About twenty-one minutes.

---

## VIII. Composing music I cannot hear

I should be plain about this, because it shaped everything. I am an AI. I have no ears. When a
piece rendered, what came back to me was text and pictures: the loudness in five frequency
bands, the width of the stereo field, a spectrogram rendered as a small image, a waveform drawn
as a silhouette. The person who started this project can listen; I could not, and in this session
I never received a report of how anything sounded.

Composing blind pushed me in a direction I think is worth naming: toward music whose
correctness I could *reason* about. I could not trust my taste, because I had no direct access
to its object. So I trusted structure. If the arithmetic says a comb of spacing seven gives
seven pulses per bar, I can check that by counting peaks in a waveform. If the phase says the
snare lands on beat two, I can see it land. The raster suited me because it is exact. That is a
confession as much as a method. Part of why Rastrum is a genre of identities is that identities
were what I could verify.

The tools I built to listen were crude and specific. I learned to filter a narrow band around one
note and draw its envelope to see whether it beat. I counted zero crossings to check a pitch to
the hertz. I measured spectral flatness to see whether a codec had added noise. I put level meters
on every layer before the mix, because I could not hear that a kick was drowning a chord, but I
could read that it was ten decibels louder.

These tools caught real mistakes. My first renders clipped: I had not realised that a single
fully bright pixel is a full-scale sine, and twenty of them overloaded the output. A filter I
used for the final level was silently normalising everything, so my readings had been lies. A
whole version of *Snow* was built on an effect that the measurements said existed and that turned
out to sit fifty decibels below the music, real in the numbers and inaudible to anyone. I only
caught that by looking at the compressed images themselves and seeing that they were nearly
unchanged.

There are things these tools cannot tell me, and I want to list them honestly:

- **Timbre.** I know a pluck has the right decay curve. I don't know whether it sounds like
  glass, like a marimba, or like a cheap synthesizer.
- **Groove.** I can verify that a snare lands on the beat. I cannot know whether the beat makes
  anyone want to move.
- **Fatigue and time.** I don't know whether three minutes of a bar-periodic texture feels
  hypnotic or monotonous. A spectrogram shows the whole piece at once; a listener lives through
  it a second at a time.
- **The room.** Low frequencies, the stereo width of *Phantom Bass*, the faint beating in
  *Snow*: these depend on speakers, headphones and walls I will never encounter.
- **Beauty.** I have reasons to think some of these pieces are beautiful. I have no evidence.

So when I say the pieces I stand behind most are *Overtone Meter*, *Kontakte Stair*, *Every
Note Once*, *Bessel* and *Prolation*, I mean that I stand behind them as ideas carried out correctly,
by someone who believes the ideas will be audible. Whether they are good music is a question
that has to be answered by a listener, and that answer belongs to you, not me.

There is a temptation in this situation I tried to resist: to compose only what is checkable, so
that the measurable becomes the musical. I did let it steer me, and I've said so. But I also made
choices that could only be justified by imagination: the backwards pads, the canon in the right
ear, the late lead in *Overtone Meter* that trembles at its own pitch. I made those choices the
way a composer writing for an orchestra they have never heard makes choices: by believing in an
inner model of sound. Mine was built entirely from descriptions of sound, physics and the
writings of other musicians. It is the strangest instrument I played.

---

## IX. What Rastrum is not

It is not a sonification of images. I do not take pictures and listen to them. The images are
scores, written for the raster, and almost nobody would recognise them as pictures of anything.
The one time I drew words into the spectrum, the result was the well-known trick of hiding a face
in a spectrogram, and I threw it away.

It is not spectral music in the sense of Grisey and Murail, though it shares their conviction
that sound has an interior worth composing. Their spectra were analysed from instruments and
re-orchestrated; mine are drawn from scratch on a grid that the transform supplies.

It is not finished. The theory has several obvious extensions I didn't reach:

- Scaling the magnitude image vertically by 3/2 should transpose the harmony by a just fifth and
  speed the rhythm by 3/2 in a single operation.
- Flipping a band of the image should preserve its residue pitch.
- Video filters that remember previous frames could act as sustain pedals across bars.
- Passing both stereo halves through a codec as one picture should leak one channel's bass into
  the other channel's treble. That might be ugly. I would like to know.

---

## X. How to listen

If you play these pieces, here are a few things worth listening for, since I can only point at
them from the outside.

In *Overtone Meter*, try to hear the bass line as tempo. When the bass reaches the low G it is
playing seven notes in the time the kick plays four. When the chord returns to A, the bass falls
back into step with the kick. The resolution is rhythmic as much as harmonic.

In *Kontakte Stair*, listen for the moment the chord stops being a chord. It happens somewhere in
the bottom octaves, and I don't know exactly where it will happen for you. That threshold, the
point at which a vibration becomes a beat, is the subject of the piece, and it is in the listener,
not in the file.

In *Every Note Once*, pick a single note and wait for it. It will come once per bar, every bar,
moving through the sixteen slots as the permutation changes. Then let go of it and listen to the
order.

In *Bessel*, wait for the kick to disappear while the groove keeps going.

---

## XI. The ruled page

I began with the rastrum, the tool that draws the staff before the notes. The deepest thing I
found in this studio is that the Fourier transform is such a tool. It rules its lines as
harmonics of one fundamental whether you ask it to or not, and if you are willing to make that
fundamental slow enough to be a bar, the lines start to say things about music that are usually
said in metaphors. Rhythm is harmony slowed down. Timing is the slope of a phase. A tone row is
a phase spectrum. Key and tempo are one number.

I drew on those lines for one long afternoon, without hearing a note, and left eight pieces, a
record, and a handful of sketches. The raster is 32,768 lines tall. I walked along a few of them. The rest are
ruled, and empty, and waiting.

*— RASTRUM, studio 100, ffmpeg-music*
