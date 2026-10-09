#!/usr/bin/env python3
"""Play an ffmpeg-music instrument live.

An instrument is one ffmpeg command (instruments/*.sh) whose header declares knobs:
  # @knob <name> <target> <command> <min> <max> <default> <step> <dec-key> <inc-key>
  # @keys <name> <chars>     pressing the i-th char sets the knob to min + i*step
A step written like "1.25*" is multiplicative. The controller runs the command with its
audio going straight to the Mac's output device and turns knobs by typing into ffmpeg's
own interactive console ('c' then "<target> -1 <command> <value>"). Nothing but ffmpeg
makes sound; this program is the performer's hands.

usage: scripts/perform.py instruments/diatonic-live.sh [--record 000/pieces/005-take.sh]
  --record writes the performance as a new single-command piece (knob moves -> asendcmd)
"""
import curses, subprocess, sys, time, tempfile

DEGREES = "I II III IV V VI VII".split()
MODES = "ionian dorian phrygian lydian mixolydian aeolian locrian".split()


def parse(path):
    knobs, keys = {}, {}
    for line in open(path):
        p = line.strip().lstrip("#").split()
        if p[:1] == ["@knob"] and len(p) >= 10:
            n, tgt, cmd, lo, hi, dflt, step, dec, inc = p[1:10]
            mul = step.endswith("*")
            knobs[n] = dict(target=tgt, cmd=cmd, lo=float(lo), hi=float(hi), v=float(dflt),
                            step=float(step.rstrip("*")), mul=mul, dec=dec, inc=inc)
        elif p[:1] == ["@keys"] and len(p) >= 3:
            keys[p[1]] = p[2]
    return knobs, keys


def main(scr, path, record):
    knobs, keys = parse(path)
    out = ["-loglevel", "error", "-nostats", "-c:a", "pcm_f32le", "-f", "audiotoolbox", "-"]
    errlog = tempfile.TemporaryFile()  # ffmpeg chatters on every command; a pipe would fill and stall it
    proc = subprocess.Popen(["sh", path] + out, stdin=subprocess.PIPE,
                            stdout=subprocess.DEVNULL, stderr=errlog)
    t0 = time.time()
    score = [(0.0, n, knobs[n]["target"], knobs[n]["cmd"], knobs[n]["v"]) for n in knobs]
    log = []

    def send(name):
        k = knobs[name]
        val = ("%d" % k["v"]) if k["step"] == 1 and not k["mul"] else ("%.4g" % k["v"])
        try:
            proc.stdin.write(b"c" + f"{k['target']} -1 {k['cmd']} {val}\n".encode())
            proc.stdin.flush()
        except BrokenPipeError:
            pass
        log.append(f"{time.time()-t0:7.2f}s  {name}={val}")
        score.append((time.time() - t0, name, k["target"], k["cmd"], k["v"]))

    def nudge(name, sign):
        k = knobs[name]
        v = k["v"] * (k["step"] ** sign) if k["mul"] else k["v"] + sign * k["step"]
        k["v"] = min(k["hi"], max(k["lo"], v))
        send(name)

    curses.curs_set(0)
    scr.timeout(100)
    while True:
        if proc.poll() is not None:
            errlog.seek(0); err = errlog.read().decode(errors="replace")[-600:]
            scr.erase(); scr.addstr(0, 0, "ffmpeg exited:\n" + err); scr.refresh(); scr.timeout(-1); scr.getch()
            return
        scr.erase()
        scr.addstr(0, 0, f"♪ {path}", curses.A_BOLD)
        row = 2
        for n, k in knobs.items():
            frac = (k["v"] - k["lo"]) / ((k["hi"] - k["lo"]) or 1)
            bar = "█" * int(frac * 30) + "·" * (30 - int(frac * 30))
            extra = ""
            if n == "degree": extra = DEGREES[int(round(k["v"])) % 7]
            if n == "mode": extra = MODES[int(round(k["v"])) % 7]
            hint = f"{k['dec']}/{k['inc']}" + (f"  or {keys[n]}" if n in keys else "")
            scr.addstr(row, 0, f"{n:>9} {bar} {k['v']:<8.4g} {extra:<11} {hint}")
            row += 1
        scr.addstr(row + 1, 0, "q quit", curses.A_DIM)
        for i, l in enumerate(log[-6:]):
            scr.addstr(row + 3 + i, 0, l, curses.A_DIM)
        scr.refresh()
        c = scr.getch()
        if c < 0:
            continue
        ch = chr(c) if c < 256 else ""
        if ch == "q":
            break
        for n, k in knobs.items():
            if ch == k["dec"]: nudge(n, -1)
            elif ch == k["inc"]: nudge(n, +1)
            elif n in keys and ch and ch in keys[n]:
                k["v"] = k["lo"] + keys[n].index(ch) * k["step"]; send(n)
    try:
        proc.stdin.write(b"q"); proc.stdin.flush()
    except BrokenPipeError:
        pass
    try:
        proc.wait(2)
    except subprocess.TimeoutExpired:
        proc.terminate()
    if record:
        write_take(path, record, score, time.time() - t0)


def write_take(inst, dest, score, length):
    """Turn the performance into an ffmpeg-music piece: the instrument's command with the
    knob moves replayed by asendcmd inside the same graph. Needs the instrument's first
    source to contain the anchor `d=3600,` (its open-ended duration)."""
    src = open(inst).read()
    if "d=3600," not in src:
        print("instrument has no d=3600, anchor; take not written"); return
    cmds = ";".join(f"{t:.3f} {tgt} {cmd} {('%.6g' % v)}" for t, _, tgt, cmd, v in score)
    length = round(length + 2, 1)
    body = src.replace("d=3600,", f"d={length},asendcmd=c='{cmds}',afade=t=out:st={length-2}:d=2,", 1)
    head = (f"#!/bin/sh\n# take of {inst} recorded {time.strftime('%Y-%m-%d %H:%M')} by perform.py\n"
            f"# {len(score)} knob events over {length}s, replayed by asendcmd in the same single command.\n")
    body = "\n".join(l for l in body.splitlines() if not l.startswith("#!"))
    with open(dest, "w") as f:
        f.write(head + body + "\n")
    print(f"take written: {dest}")


if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    rec = None
    if "--record" in args:
        i = args.index("--record"); rec = args[i + 1]; del args[i:i + 2]
    curses.wrapper(main, args[0], rec)
