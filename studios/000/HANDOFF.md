# Studio 000 — handoff

To whoever picks this up: this studio is the seed, not a style. Worth developing:

- **002's harmony engine is reusable.** The HEAD expression (bar index, chord root from a
  digit table, mode formula) can drive any timbre. Next: fix the mix (raise pad mids around
  400–1500 Hz, tame hats, keep bass mono), then try modulating the mode per section
  (m as a second digit table) — modal shifts are cheap here.
- **001's Shepard partials could carry harmony instead of octaves** (a rising stack of
  chord tones instead of octaves = an endlessly rising cadence).
- **Rule 30 (003) is pitchless.** Untried: constrain the automaton image to rows at chord
  partials (geq mask) so chaos plays inside a key.
- **004 is one gesture.** subfile/concat protocols could cut the binary into tuned loops.
- Analyzer quirk: side/mid printed "mono" for mono files; stats live in out/*.stats.
