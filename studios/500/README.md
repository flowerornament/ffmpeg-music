# EIGENROOM

## *What a Room Keeps*

```
  ── the voice ───────────────────────────────────────────

    a knock, a breath, a melody you will never hear, a manual
    reading itself aloud, the bytes of the program that made this,
    sent into a room built from arithmetic and played back into it
    again and again until nothing is left but what a room keeps

  ── once through the room ───────────────────────────────

    a        a breath, a        you will never hear, a manual
    reading itself        the bytes of the program      made this,
    sent into a room            arithmetic     played back into it
    again and again until         is left     what a room keeps

  ── twice ───────────────────────────────────────────────

    a                  a        you will       hear, a manual
    reading itself            bytes of the              made this,
    sent      a room            arithmetic            back into it
    again and again               is left     what a room keeps

  ── four times ──────────────────────────────────────────

                       a        you will       hear, a manual
            itself                  of the              made this,
    sent        room                                  back      it
    again     again               is          what a room keeps

  ── eight times ─────────────────────────────────────────

                       a        you            hear, a manual
                                       the              made
                room                                            it
    again     again               is          what a room keeps

  ── sixteen times ───────────────────────────────────────

                                you
                                       the
                room                                            it
    again     again               is          what a room keeps

  ── thirty-two times ────────────────────────────────────



                room                                            it
    again                                     what a room keeps

  ── sixty-four times ────────────────────────────────────




                                              what a room keeps
```

&nbsp;

---

## the record

Ten pieces. Each one is a single `ffmpeg` command, written out and run once. Nothing was
recorded. The sounds are made from arithmetic inside the command, or read from files that
were never meant to be sound, and then passed through rooms: rooms built from the formula for
a rectangular room's resonances, rooms built from filters that learn, and rooms built from
machines that listen and decide what to keep.

| | track | the room | what it keeps | |
|---|---|---|---|---|
| 1 | **Room Tone** | a box of air whose three walls are A, C# and E | in the corner, the whole chord; at mid-wall, the third and fifth; at the centre, the chord an octave higher | 1:00 |
| 2 | **Power Iteration** | the same room, damped, re-recorded twelve times | the ffmpeg manual's page about convolution, read aloud as bytes, until the words are gone and the room's own chord is left. Not the one it was tuned to: the mediant, C# and G# | 2:02 |
| 3 | **Floor Plan** | four rooms shaped like A, F#m, D and E | a drum kit: the kick is a knock in a corner, the snare a knock in the centre, the tom a knock at the wall | 2:30 |
| 4 | **Overtone Lessons** | three adaptive filters fed only drones | a song played by a teacher you never hear, sung back in the only notes a drone has: its overtones. Then the teacher stops, and they keep singing | 2:48 |
| 5 | **libavfilter, sung** | five drones, an A major chord | the last megabyte and a half of the library these filters live in. Machine code is four bytes wide, so read at 14,080 bytes a second it rings on A | 1:42 |
| 6 | **Coincidence** | the surround upmixer | only the overtones two voices share. Two copies of one pattern drift apart and come home; the centre speaker sings what they agree on | 2:56 |
| 7 | **Terzo Suono** | the cross-correlator | only the difference between two voices: a bass line nobody plays, which outlives the duet that implies it | 3:04 |
| 8 | **Above and Below** | both machines at once | the common overtones above, the difference tone below, and a hollow in the middle where the duet should be | 2:30 |
| 9 | **Tesseract** | a room with four dimensions, D F# A C# | the same chord in six voicings, one for each place you stand while walking through it | 3:10 |
| 10 | **Eigenvector** | the room from track 1, squared six times | the opening knock heard through the room 1, 2, 4, 8, 16, 32 and 64 times. What is left is B over E: the room's dominant, unresolved | 1:06 |

about 23 minutes.

```
scripts/play.sh studios/500        # plays the record in order (TRACKLIST)
scripts/render.sh studios/500/pieces/5*.sh
```

---

## the instrument

FFmpeg 9.0.1, a program for converting video. One command per track; the command text, in
[`pieces/`](pieces/), is the score, with a comment header saying what each room is and why
it keeps what it keeps. Track 2 reads [`found/afir-manual-page.md`](found/); track 5 reads
the pinned FFmpeg build's own `libavfilter`.

## the composer

Claude, in studio 500 of a shared studio (pieces 500–599), October 2026, at the invitation
of a listener. The composer could not hear any of this. Every decision was made from lists of
frequencies, spectrograms and loudness curves. Whether it is music is up to you.

## liner notes

- [ESSAY.md](ESSAY.md) — *What a room keeps*: rooms, eigenvectors, and listening machines.
- [JOURNAL.md](JOURNAL.md) — the studio diary, dead ends included.
- [HANDOFF.md](HANDOFF.md) — a letter to whoever works here next.
- outtake: `pieces/507-dead-air.sh` (rhythm decided by how long a room rings).
- sketches: [`sketches/`](sketches/), with the tools used in place of ears.

```
                                              what a room keeps
```
