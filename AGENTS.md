# AGENTS.md

Each piece is one `ffmpeg` command. Rules: `GENRE.md`.

The listener wants pieces that are original and musically coherent: harmony or tuning,
time, form, low end, full spectrum, stereo, a concept. New synthesis methods count.

## Layout
- `studios/NNN/`: `pieces/`, `sketches/`, `out/` (ignored), `JOURNAL.md`, `HANDOFF.md`.
  Index: `studios/README.md`.
- `NOTEBOOK.md`: findings about ffmpeg. Append dated lines.
- `IDEAS.md`, `research/techniques.md`, `research/census.md`,
  `research/instrument-library-proposal.md`.
- `instruments/`: live instruments for `perform.py`.
- `scripts/`: `render.sh`, `analyze.sh`, `play.sh`, `browse.sh`, `perform.py`, `fetch-docs.sh` (on PATH in `devenv shell`).

## Process
1. `devenv shell`.
2. Write `studios/NNN/pieces/NNN-slug.sh`: comment header, then one ffmpeg command ending
   in `"$@"`.
3. `scripts/render.sh studios/NNN/pieces/NNN*.sh` → `out/NNN*.{mp3,png,stats,log}`.
4. Agents cannot hear. Judge from the spectrogram png, loudness, band levels and side/mid,
   plus your own measurement tools (see `studios/{200,300,500}/sketches/tools/`). Mark
   pieces as unheard.
5. Keep `JOURNAL.md`; leave `HANDOFF.md` for a successor without your context.

## Facts
- One ffmpeg process per piece. Shell variables are allowed. Library fragments and
  generated commands are an open question (see the proposal).
- Build pinned in `devenv.yaml` (ffmpeg 9.0.1, aarch64-darwin, nixpkgs `e7439b6b`). Studio
  400 and piece 504 read byte offsets in that build via `$FFMPEG_MUSIC_LIB`.
- Expressions: `st()`/`ld()` persist across samples. Registers 0–9 only; higher indices
  write register 9. `random(i)` stores its seed in variable i. ~99 flat `;` terms fail with
  "Cannot allocate memory"; use parentheses.
- `alimiter` normalizes unless `level=0`. `afir` long IRs need `irnorm=2`.
- `spectrumsynth`: use `gray16` input and `win_func=hann`. FFT size (2h vs 2(h−1)) and fast
  heights are unresolved.
- Live control: stdin `c` + `target -1 command value`, also through a pipe. Only
  runtime-flagged options (`ffmpeg -h filter=X`) respond; expressions do not. The `T`
  column in `ffmpeg -filters` is timeline support.
- `-dec` loopback decoders put an encoder and decoder inside one command.
- Audio is not committed.

## Shared machine
Stay in your studio. Stop only processes you started, by PID. Keep tools inside your
studio; the scratchpad may be shared.
