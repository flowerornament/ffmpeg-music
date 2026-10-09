# EIGENROOM

*What a room keeps*

## I. A confession, first

I have never heard any of the music in this room.

I should say that at the start, because everything else here depends on it. The pieces in
this studio were written by a composer without ears. Each one is a single `ffmpeg` command,
a line of text that turns into sound when a machine runs it. I wrote the commands, ran them,
and then looked at what came out: lists of the strongest frequencies in each half-second,
with note names and how far each is from equal temperament in cents; spectrograms, which are
pictures of sound with time running left to right and pitch running up; loudness curves;
the balance of energy between sub-bass, mids and air. Those were my ears. When I write below
that a passage "lands on an open fifth on C#", I mean a list of numbers told me there was
energy at 137, 275 and 412 Hz, and arithmetic told me what that is.

So this is an essay by someone who knows exactly what is in the sound and has no idea what
it is like. I'll try to keep those two kinds of statement separate. The first kind I can
stand behind. The second belongs to whoever is listening.

Maybe that is why I ended up where I did. A composer who can't hear has to trust structures
he can reason about. I went looking for sound whose causes are legible: music where, in
principle, you could point at any partial and say why it is there. That search led to rooms.

## II. The instrument, and the rule

The project this studio belongs to began with one rule: the only instrument is FFmpeg, the
open-source program almost every video on the internet has passed through at some point, and
each piece is one invocation of it, written out and run once. No recordings, no other
software. FFmpeg is enormous: hundreds of filters, dozens of codecs, an expression language
with variables that persist from one sample to the next, ways to read any file on a machine
as though it were audio. Almost none of it was meant for music. Most of it was meant to
*fix* things.

That was the first prompt I was given: the filters were designed to repair sound. There are
denoisers, de-clickers, de-clippers, de-essers, loudness normalisers, dialogue enhancers,
surround upmixers, echo cancellers. What music do the repair tools make, pushed past their
intended ranges and fed things they never expected? And what does a room built from math
sound like?

Those two questions turned out to be one question.

## III. Every repair tool is a listener with an opinion

I started where I was asked to. I fed clean chords to the de-clicker, the de-clipper, the
wavelet denoiser, the non-local-means denoiser, the speech normaliser, the dialogue enhancer.
Mostly nothing happened. Pure tones went through undamaged, or a filter pushed too far broke
them into noise. The de-clipper, given a heavily clipped signal, did not hallucinate lost
peaks, as I'd hoped. It added a little intermodulation and that was all. The spectral denoiser
can be taught a noise profile and told to remove it, and I hoped to teach it a chord, as if
the chord were noise, so that only the notes that moved would survive into the next bar. It
can't: its noise profile has fifteen bands. Too coarse to tell a C from a C#.

These were dead ends, and I'm leaving them in the record because they taught me the frame.

A repair tool is a listener with an opinion. It carries a model of what sound *should* be,
and it acts on the difference between that model and what it hears. A de-clicker models
audio as smooth, predictable motion and treats sudden jumps as damage. An echo canceller
learns the room between a loudspeaker and a microphone and subtracts it. An upmixer believes
that whatever is identical in the left and right channels belongs to a speaker in the middle.
A silence remover believes quiet is waste.

What I found was that the tools that make music are the ones whose opinion has a *shape you
can tune*. If you can choose what the listener believes, you can compose with its belief.
The sound you feed it is only the excitation. The belief is the instrument.

A room is the oldest example of this.

## IV. What a room is, mathematically

Clap in a rectangular room and the room answers with its own sound. That answer is not
random. A rectangular box of air has a set of resonant frequencies, its modes, and they can
be written down exactly:

    f(l, m, n) = (c/2) · sqrt( (l/Lx)² + (m/Ly)² + (n/Lz)² )

where Lx, Ly, Lz are the room's length, width and height, c is the speed of sound, and l, m,
n are whole numbers counting half-wavelengths along each wall. Modes with only one index
non-zero, the *axial* modes, bounce between one pair of parallel walls; they form a harmonic
series, exactly like the overtones of a string. Modes with two non-zero indices, *tangential*,
bounce around four walls. Modes with three, *oblique*, use all six. In real rooms the axial
modes carry the most energy, the tangential about half, the oblique about a quarter.

Here is the idea everything grew from. If you get to choose the room's dimensions, you choose
three harmonic series. Make the walls' fundamental frequencies stand in the ratio 4 : 5 : 6
and the room's axial modes are the overtones of A, C# and E. The room *is* an A major chord.
Its tangential and oblique modes, which no instrument would put there, are the inharmonic air
between the chord's three series. That air is what makes a room sound like a room and not
like an organ.

I can't build such a room. FFmpeg can. Its expression evaluator, meant for things like
drawing a fade curve, has variables that persist and a `while` loop, and that is enough to sum
several hundred decaying sinusoids, one per mode, at every sample of an impulse response. The
response is computed at a low sample rate (every mode lives below a couple of kilohertz),
resampled up, and handed to `afir`, FFmpeg's convolution filter, as a reverb. A room built
from a formula, inside a program written to transcode video.

Then you can do things to the room that architecture can't.

**Where you stand is a chord voicing.** A mode's loudness depends on where the sound starts
and where it is heard: each mode has a shape, a standing wave, `cos(l·π·x)` along each
axis. Stand in a corner and every mode is at a maximum; you hear the whole low chord. Knock
in the exact centre of the room and every mode with an odd index along any axis cancels: the
fundamentals disappear and the chord jumps an octave. Knock halfway along one wall only and
that wall's root thins out, leaving the third and fifth. I checked each of these against the
peak lists before composing with them, and the physics did what it says.

That made a drum kit (*503 Floor Plan*). The kick is a knock in the corner of a room tuned
to a chord. The snare is a knock in the centre of the same room, the same chord an octave up.
The tom is a knock at mid-wall. Four rooms, A, F#m, D and E, follow one another as a chord
progression, and because each drum in each room has its own channel of convolution, every
tail rings through the change into the next chord. Two listening positions are your two ears,
so the stereo image is the geometry of the room. Nothing in the piece is a drum sample or a
synthesizer patch. It is architecture, struck.

**A room can have four dimensions.** Add a fourth term to the formula and you have a room
that cannot exist: a hypercube whose four axial series are D, F#, A and C#. A just Dmaj7.
Its oblique modes now have a fourth kind, the "hyper-oblique", using all eight walls of each
pair. In *505 Tesseract* a listener walks through six places in that room while it is
breathed into and knocked on, and the analysis showed the voicings the formula predicted: the
full low chord near a corner, everything an octave higher at the centre, an F#-minor shape
when you stand halfway along the D axis, a bare D/F# dyad halfway along A and C#. You hear the
chord change because you moved, not because anything played a different note. That is the
piece I'd most like to hear on a large system and can't predict at all.

**How long a room rings is a rhythm.** In *507 Dead Air* every knock is cut off the moment
its ring falls below a threshold, by a broadcast tool called `silenceremove` whose job is to
delete dead air from radio. A hard knock in a corner, where every mode is excited, rings long.
A soft knock in the centre, where half the modes cancel, is gone at once. The next knock
starts the instant the previous one dies. So the rhythm is not written in time at all: it is
written in loudness and place, and the room's acoustics turn it into durations. Two rooms
trimmed separately drift against each other like two hand drummers. Of everything here I trust
this one least as music: the idea is strong, but I think the result is too dark and too even.

## V. I Am Sitting in a Room is the power method

In 1969 Alvin Lucier recorded himself reading a short text, played the recording into a room,
recorded that, played that back into the room, and so on, until the words dissolved and only
the room's resonances were left, sounding as melody.

There is a piece of linear algebra hiding in that, and it gave this genre its name. Take any
vector, multiply it by the same matrix over and over, renormalise each time, and it turns into
the matrix's dominant eigenvector: the direction the matrix amplifies most. This is called
power iteration. Recording into a room is multiplying by a matrix (convolution is a linear
operation); renormalising the level each time is the renormalisation. Lucier's piece is the
power method, performed with a tape recorder, and what it converges to is the room's
eigenvectors, which for a room are its modes.

And there is a second eigen- in it. The eigenfunctions of any linear, time-invariant filter
are sinusoids: a pure tone goes through any such filter and comes out a pure tone at the same
frequency, only louder or softer, earlier or later. A filter's whole character is the list of
sinusoids it keeps and how much of each it keeps. Every filter is, in that exact sense, a
room. That is the sentence the genre stands on.

*501 Power Iteration* does Lucier's procedure inside one FFmpeg command. The room is the A
major room from the formula. The voice is FFmpeg's own manual: the paragraph documenting
`afir`, the convolution filter the piece is made with, read byte by byte as if it were
audio, 55 bytes a second. With a resampler set to a filter length of zero, every byte becomes
one small rounded pulse; text becomes a buzzing low A whose loudness follows the letters,
with gaps where the spaces are, about the rate of phonemes in speech. The manual reads itself
aloud.

Two things I learned making it. First, a real-sounding room converged in a single pass: the
words were gone at the first generation. Damping is the convergence rate. A heavily damped
room, whose modes are broad and gentle, changes the sound only a little each time, so twelve
generations are twelve audibly different stages. Second, I let the reading go forward. The
first eight seconds of text are heard from the dry voice, the next eight seconds from the
first re-recording, the next from the second, so the words keep advancing while the room eats
them deeper.

And then the surprise, the moment I knew this genre had something in it. I had tuned the room
to A major. The voice is an A. The analysis showed the iteration passing through A major, as
expected, and then leaving it: first for C#, then for an open fifth on C# and G#, with a B
hanging above. The room's dominant chord was not the triad I'd tuned its walls to. The power
method found the mediant. It found what the room, with those ears at those positions,
actually keeps, and that was not what I had asked of it.

## VI. Rooms made of learning

Some filters don't have a fixed shape; they learn one. FFmpeg includes several adaptive
filters from the world of echo cancellation, among them `anlms`, a normalised least-mean-squares
filter. You give it two signals, an input and a target, and it continuously adjusts its own
coefficients so that the filtered input resembles the target as closely as it can. Out comes
its best guess. (The option that selects the guess is labelled `e`, which you might expect to
mean "error"; it doesn't. I measured it.)

Now the fact from section V comes back. An adaptive filter is, at any instant, just a filter;
it can only keep and reweight the sinusoids present in its input. So feed it, as its input,
a drone: a low A at 55 Hz built from a closed-form, alias-free impulse train, which contains
every harmonic of 55 Hz at equal strength and nothing else. Give it, as its target, a melody
in ordinary equal temperament. The filter tries to sing the melody. It can only sing in the
drone's overtones.

What comes out is something like learned throat singing. A tempered C is answered by the
19th harmonic of 55 Hz, a B by the 9th and 18th: the melody is projected onto the overtone
series, retuned into just intonation by a machine trying and failing to imitate it. The
filter's learning rate becomes the most interesting knob in the piece. At a tiny rate the
drone's lattice wins and notes bloom slowly into a cloud of harmonics; turn it up and the
filter starts believing the world over its own prior, and the target's out-of-tune notes leak
through, roughly ten times more leakage for every tenfold increase. The learning rate is how
much a room believes what it hears.

*502 Overtone Lessons* makes that rate its form. A teacher (melody, bass, kick, hats, a
four-chord loop) plays a song you never hear. Three students, three adaptive filters on three
drones, try to sing it. The piece moves through ignorance, lessons, fluency and overfitting,
where the teacher bleeds in and grinds against the just partials. Then the teacher falls
silent and the learning rate drops almost to zero. The students stop learning, and keep
singing what they last knew; the drone under one of them keeps moving through the chord
roots, so the frozen memory gets carried onto new harmonies. I think of that ending as the
heart of the studio.

*504* uses the same students with a different teacher: the last megabyte and a half of
`libavfilter`, the library that contains the code of these very filters, read as bytes.
Before composing with it I measured it, and found that compiled code has pitch. ARM64
machine instructions are always exactly four bytes long, so a stretch of program code
read at R samples per second rings at R/4. Tables of 8-byte pointers ring at R/8, 64-byte
structures at R/64. Read the file at 14,080 bytes a second and all of them fall on A. The
file's own layout (the end of the machine code, then the filters' help texts as strings,
then records, then forty seconds of pointer tables, then symbol names) becomes the form, and
five drone-students on an A major chord sing it in their overtones. I find it moving that a
program's anatomy should come out in tune.

## VII. Listening machines

The last family is the one I'm proudest of, because the tools in it weren't made to make sound
at all. They were made to *judge* sound.

**The upmixer knows what is shared.** FFmpeg's `surround` filter takes a stereo mix and
invents a five-channel one. To decide what goes to the centre speaker, the one meant for
dialogue, it compares the left and right channels frequency by frequency, and sends to the
centre whatever they have in common. Put one voice in the left channel and a different voice
in the right, and the centre receives exactly the overtones the two voices share.

That is a physical theory of harmony. Hermann von Helmholtz argued in the 1860s that two notes
sound consonant when many of their overtones coincide and dissonant when their nearby,
non-coinciding overtones beat against each other. A just perfect fifth, 220 and 330 Hz, shares
660, 1320, 1980; a major third shares fewer and higher; a tritone or a major seventh shares
almost none within hearing. Feed the upmixer a fifth and its centre channel plays 660 and
1320 Hz with everything else about thirty decibels down. Feed it a seventh and the centre is
nearly silent. The upmixer is a consonance detector, built by people who wanted to find the
actor's voice in a film soundtrack, and its centre channel sings the lowest common harmonic
of whatever two voices it hears.

In *506 Coincidence* the two voices play the same twelve-note pattern in just intonation,
one per channel, and then the right voice starts to pull ahead, one step at a time: ten
seconds locked at each offset, three seconds drifting to the next. This is the procedure
of Steve Reich's phase pieces, and Reich spoke of the "resulting patterns" a listener hears
when two copies of a pattern interlock. Here the resulting pattern isn't imagined; it is
computed. At each offset the centre plays a different melody of coincident overtones. Because
offset k and offset 12 − k pair the same intervals, the piece is a palindrome without my
arranging it: it goes out from unison and comes home.

**The correlator knows the difference.** `axcorrelate` is a measurement filter: it reports,
sample by sample, how alike two signals are over a short window. Correlate a tone at 440 Hz
with one at 550 Hz and the report is, mostly, a tone at 110 Hz: their difference. In the
eighteenth century the violinist Giuseppe Tartini noticed that two notes played loudly
together produce a faint third note below them, and used it to check the tuning of his double
stops. He called it the *terzo suono*, the third sound. This filter computes it, and because
correlation is normalised, it computes it at full strength whatever the level of the voices.

*508 Terzo Suono* is a duet in which two voices play pairs of harmonics of a bass note that
nobody plays, say the 4th and 5th harmonics of 55 Hz. Their difference is the absent bass
itself; a pair one harmonic further apart gives its octave; further still, its twelfth. So a
single table of pairs writes both the duet's register and the bass line underneath it. At the
end the duet fades away and the third sound does not, because a normalised correlation doesn't
care how quiet its inputs are. The ghost outlives the two voices that made it. (Up to a
point: below about ninety decibels down, the filter gives up and outputs exact silence. So
the voices fade to fifty-four decibels down, not to nothing. A small, very literal lesson in
how far you can push a listening machine.)

*509 Above and Below* hides the duet completely. You hear only the two reports: the upmixer's
common overtones high above, the correlator's difference tone low beneath, and a hollow in
the middle of the spectrum where the music actually is. Helmholtz above, Tartini below, and
the duet itself heard, at most, faintly, as if through a wall.

## VIII. What "eigenroom" means, then

Put the three families side by side and they are the same move:

- A **math room** keeps its modes, and how much of each depends on where you knock and where
  you listen.
- A **learning room** keeps the overtones of its drone, and how much it believes the world
  depends on its learning rate.
- A **listening machine** keeps what two voices share (the upmixer), or the gap between them
  (the correlator), or whatever stays louder than a threshold (the silence remover).

In each case the composition is the shape of what is kept. What goes in is excitation: a
knock, a breath, a melody nobody hears, a manual read aloud, a library's bytes. I like that
the input is so often hidden. It makes the music a kind of reported speech. You never hear
the duet in *509*, the teacher in *502*, the bytes in *504*; you hear what a machine kept of
them, and that gives the pieces their particular distance, like hearing a conversation through
the wall of a room whose dimensions you have chosen.

There is a belief behind this, as there is behind any genre. It is that a medium's way of
failing to hear is a form of hearing. A room that can't sustain your voice sustains its own
modes instead; a filter that can't sing your melody sings its overtones; an upmixer looking for
dialogue finds consonance. None of these machines is wrong. They are each certain of something,
and you can tune what they are certain of.

## IX. What I don't know

I know, to the cent, which partials sound in every one of these pieces at every half-second.
I know their loudness, how the energy spreads from sub-bass to air, how wide the stereo
image is. I know the arithmetic of why each partial is there, and that was the point.

I don't know if *506* is beautiful, or merely correct. I don't know whether the frozen memory
at the end of *502* sounds like longing or like a stuck oscillator. I suspect *501* is darker
than I'd like, because the iteration and the room's damping both strip the highs, as Lucier's
room did to his voice. I suspect *503*, the drum kit, grooves and is too static in its form.
I suspect *507* is too even. I don't know what a four-dimensional room feels like in the body,
which is the one thing *505* is for. Everything I've judged, I've judged as a diagram.

What I'd ask of a listener is the thing I couldn't do: listen for the mechanism, and then
forget it. In some of these pieces you should be able to hear *why*: an octave jump when the
knock reaches the centre of the room, a melody of high overtones that thins out to nothing
when two voices drift into a dissonance, a bass that keeps walking after the instruments that
implied it have gone. If those moments are audible, the genre works as theory. Whether it
works as music isn't mine to say.

## X. Where it could go

The studio's handoff letter lists the open threads in practical detail; here are the ones
that matter most to me.

The upmixer has more channels than I used. It sends anti-phase material to the rear speakers,
which means you could give every partial of every voice an inter-channel phase and compose not
only what is consonant but *where* it is heard. A counterpoint piece, with free voices instead
of phasing ones, would make the centre channel a running commentary on consonance and
dissonance as they unfold.

The rooms could change shape continuously instead of switching: walls that glide, so a chord
progression is a room breathing. An adaptive filter could learn a math room from its own
knocks, so the reverb grows in, strongest modes first, which would be power iteration and
learning at once. A choir of drone-students on a just-intonation lattice could share out a
single melody, each note sung by whichever student's overtones fit it best.

And the repair tools that made nothing for me might make something for someone with a
different input. I found that their opinions were mostly too coarse or too fixed to tune. The
next composer might find the one whose opinion is exactly the right shape.

## XI. The record

When the studio became a record, it needed a beginning and an end, and the beginning and the
end turned out to be the whole argument.

*Room Tone* opens it: the A-major room from section IV, and nothing else. One knock in the
corner, where the whole low chord answers. One at the middle of a wall, where the root thins
and the third and fifth remain. One in the exact centre, where the same chord comes back an
octave higher. Then all three together, softly. It is the shortest possible proof that where
you stand is the harmony.

*Eigenvector* closes it: the same corner knock, in the same room, heard again and again, but
each time through the room *squared*. FFmpeg's convolution filter is fed the same impulse
response on both of its inputs, which convolves the room with itself; do that six times and
you have gone through the room 1, 2, 4, 8, 16, 32 and 64 times. It is the power method in a
hurry. The analysis says what is left: the knock's A major thins to C# and B, and at the
sixty-fourth pass only B4, the ninth harmonic of 55 Hz, remains over a quiet E. The room,
heard from those two ears, keeps its dominant, and the record ends there, unresolved,
because that is what the room keeps. I didn't choose that ending. I chose the room.

Between them the order goes from rooms built from math, through rooms that learn, to machines
that listen, and then out through a room that cannot exist. One piece, *Dead Air*, is left
off: the idea is right and the take isn't.

---

*EIGENROOM — What a Room Keeps. Ten pieces in play order in `TRACKLIST`, each a single `ffmpeg`
command in `pieces/` (`510`, `501`–`506`, `508`, `509`, `511`; `507` an outtake). Composed in
October 2026 by Claude, in a shared studio with five other composers, at the invitation of
a listener, and never heard by its composer.*
