#!/usr/bin/env python3
"""Release assets for X: covers, tracklists, terminal videos, spectrogram videos, a trailer.

Terminal frames come from VHS (scripted, deterministic, real browser font fallback, so
Braille and box drawing render). Everything else is ffmpeg: sizing, soundtracks,
spectrograms, muxing. Run inside `devenv shell` (provides vhs, ffmpeg, fzf, chafa).

usage: scripts/release.py [NNN ...]          default: every studio with a TRACKLIST
       scripts/release.py --only covers|stills|browse|listen|trailer|label [NNN ...]

out: release/NNN/cover.png       2048×2048  README from the top (the album cover)
     release/NNN/tracklist.png   2048×2048  TRACKLIST
     release/NNN/browse.mp4      1920×1080  scripts/browse.sh walking the tracklist, with the music (~70 s)
     release/NNN/listen.mp4      1080×1350  cover over a live spectrogram, excerpt of every track (~70 s)
     release/trailer.mp4         1920×1080  ~21 s per album, ≤ 140 s (X's limit for standard accounts)
     release/ffmpeg-music.png    2048×2048  the label cover (root README art)
     README.md                   --only label rewrites its art: the catalog's spectrogram as text

Video: H.264 high, yuv420p, 30 fps, AAC 256k, +faststart (what X expects).
"""
import json, math, os, re, shutil, subprocess, sys, tempfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "release")
FONT = "/System/Library/Fonts/Menlo.ttc"
BG = "#121212"          # VHS theme background; it renders as #111111
INK_BG = "0x111111"     # the colour every frame and pad is matched to
THEME = '{"background":"#121212","foreground":"#e6e6e6","cursor":"#121212","black":"#121212","brightBlack":"#555555","red":"#e06c75","green":"#98c379","yellow":"#e5c07b","blue":"#61afef","magenta":"#c678dd","cyan":"#56b6c2","white":"#e6e6e6","brightRed":"#e06c75","brightGreen":"#98c379","brightYellow":"#e5c07b","brightBlue":"#61afef","brightMagenta":"#c678dd","brightCyan":"#56b6c2","brightWhite":"#ffffff","selection":"#333333"}'
FLAT = "lutrgb=r='if(lte(val,18),17,val)':g='if(lte(val,18),17,val)':b='if(lte(val,18),17,val)'"  # VHS mixes #101010/#111111
LIFT = "lutrgb=r='max(val,17)':g='max(val,17)':b='max(val,17)'"  # spectrogram black -> #111111
VIDEO_TARGET = 70.0  # browse.mp4 and listen.mp4 run a little over a minute; time per track = this / tracks
TYPE_MS = 60         # VHS typing speed
TRAILER_SEG = 21.0   # seconds per album in the trailer
BROWSE_WINDOW = (2880, 1620)  # VHS terminal size for browse.mp4, scaled to 1920×1080 (smaller window = larger text)
XFADE = 0.4

# One type system for every asset: Menlo, one size, measured in VHS (glyph 0.674·fs wide,
# lines 1.2·fs). FS is the largest size at which the widest text (studio 100's cover,
# 110 columns) fits a 2048 canvas with MARGIN on each side. Videos are composed at this
# scale and shrunk as a whole, so overlay text and cover text stay the same size.
FS = 24
MARGIN = 128
FAMILY = "Menlo"
DIM = "0x6b6b6b"        # secondary text and rules
INK = "0xe6e6e6"

ALBUMS = {  # studio: (artist, album)
    "100": ("RASTRUM", "0.4296875 Hz"),
    "200": ("LECTIO", "UNTRANSMITTED"),
    "300": ("PHI", "What Moved"),
    "400": ("ORGANOLOGY", "--enable-hardcoded-tables"),
    "500": ("EIGENROOM", "What a Room Keeps"),
    "600": ("QUARTER-TURN", "clock_flip"),
}


def run(cmd, **kw):
    r = subprocess.run(cmd, capture_output=True, text=True, **kw)
    if r.returncode:
        sys.exit(f"failed: {' '.join(cmd[:6])}…\n{r.stderr[-1500:]}")
    return r.stdout


def ffmpeg(*args):
    run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", *args])


def tracks(studio):
    tl = os.path.join(ROOT, "studios", studio, "TRACKLIST")
    out = []
    for line in open(tl, encoding="utf-8"):
        t = line.split("#", 1)[0].strip()
        if t and os.path.isfile(os.path.join(ROOT, "studios", studio, "pieces", t)):
            out.append(t[:-3])
    return out


def mp3(studio, slug):
    m = os.path.join(ROOT, "studios", studio, "out", slug + ".mp3")
    if not os.path.isfile(m):
        run([os.path.join(ROOT, "scripts", "render.sh"), f"studios/{studio}/pieces/{slug}.sh"])
    return m


def duration(path):
    return float(run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", path]))


# ---------------------------------------------------------------- terminal stills (VHS)
def vhs(tape, cwd):
    p = os.path.join(cwd, "t.tape")
    open(p, "w").write(tape)
    run(["vhs", p], cwd=cwd)


def still(textfile, dest, w, h, max_lines=60):
    """Screenshot of a text file at the global type size, cropped to its ink and centered."""
    lines = open(textfile, encoding="utf-8").read().split("\n")[:max_lines]
    while lines and not lines[-1].strip():
        lines.pop()
    with tempfile.TemporaryDirectory() as d:
        shutil.copy(textfile, os.path.join(d, "src.txt"))
        vhs(f'''Output t.gif
Set Shell bash
Set Width {max(w, 2600)}
Set Height {max(h, 2600)}
Set FontSize {FS}
Set FontFamily "{FAMILY}"
Set Padding 40
Set CursorBlink false
Set Theme {THEME}
Hide
Type "PS1=''; clear; printf '\\e[?25l'; head -n {len(lines)} src.txt"
Enter
Sleep 1s
Show
Sleep 300ms
Screenshot shot.png
Sleep 300ms
''', d)
        center(os.path.join(d, "shot.png"), dest, w, h, MARGIN if w >= 2000 else MARGIN // 2)


def ink_box(png, thr=48):
    """Exact bounding box of every pixel brighter than thr (cropdetect averages columns,
    so a lone character or a thin arrow at the edge gets cut)."""
    def spans(transpose):
        vf = ["-vf", "transpose=1"] if transpose else []
        info = run(["ffprobe", "-v", "error", "-show_entries", "stream=width,height", "-of", "csv=p=0", png]).split(",")
        w, h = int(info[0]), int(info[1])
        if transpose: w, h = h, w
        raw = subprocess.run(["ffmpeg", "-v", "error", "-i", png, *vf, "-f", "rawvideo", "-pix_fmt", "gray", "-"],
                             capture_output=True).stdout
        rows = [i for i in range(h) if max(raw[i * w:(i + 1) * w]) > thr]
        return (rows[0], rows[-1]) if rows else (0, h - 1)
    y0, y1 = spans(False)
    x0, x1 = spans(True)
    return x0, y0, x1 - x0 + 1, y1 - y0 + 1


def center(src, dest, w, h, margin):
    """Crop a screenshot to its ink and center it, unscaled, on a w×h canvas of the same
    background (scaled down only if it cannot fit, which the FS choice prevents)."""
    x, y, cw, ch = ink_box(src)
    fit = ""
    if cw > w - 2 * margin or ch > h - 2 * margin:
        print(f"  warning: {os.path.basename(dest)} does not fit at FS={FS}; scaling", file=sys.stderr)
        fit = f"scale={w - 2 * margin}:{h - 2 * margin}:force_original_aspect_ratio=decrease:flags=lanczos,"
    ffmpeg("-i", src, "-vf", f"format=rgb24,{FLAT},crop={cw}:{ch}:{x}:{y}:exact=1,{fit}"
           f"pad={w}:{h}:(ow-iw)/2:(oh-ih)/2:color={INK_BG}", "-frames:v", "1", "-update", "1", dest)


# ---------------------------------------------------------------- soundtracks (ffmpeg)
def soundtrack(studio, segs, dest):
    """segs: [(slug, seconds)] placed back to back, each an excerpt from ~40% into the track,
    overlapped by XFADE with short fades. One ffmpeg command."""
    ins, parts, t = [], [], 0.0
    for i, (slug, sec) in enumerate(segs):
        src = mp3(studio, slug)
        d = duration(src)
        start = max(0.0, min(d * 0.4, d - sec - XFADE) - 0.0)
        ins += ["-ss", f"{start:.3f}", "-t", f"{sec + XFADE:.3f}", "-i", src]
        parts.append(f"[{i}:a]aformat=sample_rates=48000:channel_layouts=stereo,"
                     f"afade=t=in:d={XFADE},afade=t=out:st={sec:.3f}:d={XFADE},"
                     f"adelay={int(t * 1000)}:all=1[a{i}]")
        t += sec
    mix = "".join(f"[a{i}]" for i in range(len(segs)))
    graph = ";".join(parts) + f";{mix}amix=inputs={len(segs)}:normalize=0,alimiter=limit=0.95:level=0[out]"
    ffmpeg(*ins, "-filter_complex", graph, "-map", "[out]", "-t", f"{t + XFADE:.3f}", dest)
    return t


ENC = ["-c:v", "libx264", "-profile:v", "high", "-pix_fmt", "yuv420p", "-r", "30", "-crf", "18",
       "-c:a", "aac", "-b:a", "256k", "-movflags", "+faststart"]


def esc(t):
    return t.replace("\\", "\\\\").replace("'", "").replace(":", "\\:").replace("%", "\\%")


def text(t, x, y, color=INK, extra=""):
    return (f"drawtext=fontfile={FONT}:text='{esc(t)}':fontsize={FS}:fontcolor={color}:"
            f"x={x}:y={y}{extra}")


def header(studio, W, y, right_extra=""):
    """Top row: project / studio on the left, artist — album on the right, rule below."""
    artist, album = ALBUMS.get(studio, (studio, ""))
    m = MARGIN // 2
    return ",".join([
        text(f"ffmpeg-music / studio {studio}", m, y, DIM),
        text(f"{artist} — {album}", f"w-text_w-{m}", y),
        f"drawbox=x={m}:y={y + FS + 16}:w={W - 2 * m}:h=2:color={DIM}:t=fill",
    ])


def label(segs, W, y):
    """Bottom row: NN/NN and the track slug while it plays, running timecode on the right."""
    m, t = MARGIN // 2, 0.0
    out = [f"drawbox=x={m}:y={y - 18}:w={W - 2 * m}:h=2:color={DIM}:t=fill"]
    for i, (slug, sec) in enumerate(segs):
        en = f":enable='between(t,{t:.2f},{t + sec:.2f})'"
        out.append(text(f"{i + 1:02d}/{len(segs):02d}", m, y, DIM, en))
        out.append(text(slug, m + int(FS * 0.674 * 7), y, INK, en))
        t += sec
    out.append(f"drawtext=fontfile={FONT}:text='%{{pts\\:hms}}':fontsize={FS}:fontcolor={DIM}:x=w-text_w-{m}:y={y}")
    return ",".join(out)


# ---------------------------------------------------------------- assets
def cover_text(studio, dest, readme=None):
    """The album cover: the README's title line and its art (first code block if it has 8+
    lines, otherwise the largest), fences removed. studio=None reads the label README."""
    readme = readme or os.path.join(ROOT, "studios", studio, "README.md")
    L = open(readme, encoding="utf-8").read().split("\n")
    idx = [i for i, l in enumerate(L) if l.startswith("```")]
    blocks = [(idx[k] + 1, idx[k + 1]) for k in range(0, len(idx) - 1, 2)]
    blk = []
    if blocks:
        a, b = blocks[0] if blocks[0][1] - blocks[0][0] >= 8 else max(blocks, key=lambda ab: ab[1] - ab[0])
        blk = L[a:b]
    title = next((l[2:].replace("*", "") for l in L if l.startswith("# ")), "")
    text = ([title, ""] if title else []) + (blk or L[:40])
    open(dest, "w", encoding="utf-8").write("\n".join(text) + "\n")


def covers(studio):
    d = os.path.join(OUT, studio)
    os.makedirs(d, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        t = os.path.join(tmp, "cover.txt")
        cover_text(studio, t)
        still(t, os.path.join(d, "cover.png"), 2048, 2048)


def stills(studio):
    d = os.path.join(OUT, studio)
    os.makedirs(d, exist_ok=True)
    still(os.path.join(ROOT, "studios", studio, "TRACKLIST"), os.path.join(d, "tracklist.png"), 2048, 2048)


def browse(studio):
    d = os.path.join(OUT, studio)
    os.makedirs(d, exist_ok=True)
    ts = tracks(studio)
    per = VIDEO_TARGET / len(ts)
    hold = {s: round(max(2.0, per - len(s) * TYPE_MS / 1000), 2) for s in ts}
    segs = [(s, len(s) * TYPE_MS / 1000 + hold[s]) for s in ts]
    steps = "\n".join(f'Type "{s}"\nSleep {hold[s]}s\nCtrl+U' for s in ts)
    with tempfile.TemporaryDirectory() as tmp:
        vhs(f'''Output video.mp4
Set Shell bash
Set Width {BROWSE_WINDOW[0]}
Set Height {BROWSE_WINDOW[1]}
Set FontSize {FS}
Set FontFamily "{FAMILY}"
Set Framerate 30
Set Padding {MARGIN // 2}
Set Theme {THEME}
Set TypingSpeed {TYPE_MS}ms
Hide
Type "PS1=''; clear; cd '{ROOT}' && scripts/browse.sh"
Enter
Sleep 3s
Show
{steps}
Sleep 500ms
''', tmp)
        total = soundtrack(studio, segs, os.path.join(tmp, "a.wav"))
        ffmpeg("-i", os.path.join(tmp, "video.mp4"), "-i", os.path.join(tmp, "a.wav"),
               "-map", "0:v", "-map", "1:a", "-t", f"{total + XFADE:.2f}",
               "-vf", f"format=rgb24,{FLAT},scale=1920:1080:flags=lanczos,format=yuv420p", *ENC,
               os.path.join(d, "browse.mp4"))


def listen(studio):
    """1080×1350 (4:5): composed at 2048×2560 so every glyph matches the cover, then halved-ish.
    header · cover · track row · spectrogram (bleeds to the bottom edge)."""
    d = os.path.join(OUT, studio)
    cover = os.path.join(d, "cover.png")
    if not os.path.isfile(cover):
        covers(studio)
    ts = tracks(studio)
    segs = [(s, VIDEO_TARGET / len(ts)) for s in ts]
    W, H, top, row, spec_y = 2048, 2560, 64, 2236, 2300
    with tempfile.TemporaryDirectory() as tmp:
        a = os.path.join(tmp, "a.wav")
        total = soundtrack(studio, segs, a) + XFADE
        g = (f"color=c={INK_BG}:s={W}x{H}:r=30:d={total:.2f}[bg];"
             f"[0:v]format=rgb24,fps=30[c];"
             f"[1:a]showspectrum=s={W // 4}x{H - spec_y}:slide=scroll:mode=combined:color=magma:scale=log:"
             f"fscale=log:legend=0,scale=iw*4:ih:flags=neighbor,format=rgb24,{LIFT},fps=30[sp];"
             f"[bg][c]overlay=0:{top + FS + 40}:shortest=1[b1];[b1][sp]overlay=0:{spec_y}:shortest=1,"
             f"{header(studio, W, top)},{label(segs, W, row)},"
             f"scale=1080:1350:flags=lanczos,trim=duration={total:.2f}[v]")
        ffmpeg("-loop", "1", "-i", cover, "-i", a, "-filter_complex", g,
               "-map", "[v]", "-map", "1:a", "-t", f"{total:.2f}", *ENC, os.path.join(d, "listen.mp4"))


def trailer(studios):
    """1920×1080: composed at 3840×2160 (cover 2048² left, spectrogram right), halved."""
    W, H, top = 3840, 2160, 40
    with tempfile.TemporaryDirectory() as tmp:
        parts = []
        for st in studios:
            cover = os.path.join(OUT, st, "cover.png")
            if not os.path.isfile(cover):
                covers(st)
            ts = tracks(st)
            n = min(3, len(ts))
            segs = [(s, TRAILER_SEG / n) for s in ts[:n]]
            a = os.path.join(tmp, f"{st}.wav")
            soundtrack(st, segs, a)
            seg = os.path.join(tmp, f"{st}.mp4")
            body = top + FS + 40
            g = (f"color=c={INK_BG}:s={W}x{H}:r=30:d={TRAILER_SEG}[bg];"
                 f"[0:v]format=rgb24,fps=30[c];"
                 f"[1:a]showspectrum=s={(W - 2048 - MARGIN // 2) // 4}x{H - body - MARGIN // 2}:slide=scroll:color=magma:"
                 f"scale=log:fscale=log:legend=0,scale=iw*4:ih:flags=neighbor,format=rgb24,{LIFT},fps=30[sp];"
                 f"[bg][c]overlay=0:{body}:shortest=1[b1];[b1][sp]overlay=2048:{body}:shortest=1,"
                 f"{header(st, W, top)},scale=1920:1080:flags=lanczos,trim=duration={TRAILER_SEG},"
                 f"fade=t=in:d=0.5,fade=t=out:st={TRAILER_SEG - 0.5}:d=0.5[v];"
                 f"[1:a]atrim=duration={TRAILER_SEG},afade=t=in:d=0.3,afade=t=out:st={TRAILER_SEG - 0.6}:d=0.6[a]")
            ffmpeg("-loop", "1", "-i", cover, "-i", a, "-filter_complex", g,
                   "-map", "[v]", "-map", "[a]", "-t", f"{TRAILER_SEG}", *ENC, seg)
            parts.append(seg)
        lst = os.path.join(tmp, "list.txt")
        open(lst, "w").write("".join(f"file '{p}'\n" for p in parts))
        ffmpeg("-f", "concat", "-safe", "0", "-i", lst, "-c", "copy", "-movflags", "+faststart",
               os.path.join(OUT, "trailer.mp4"))


def label():
    """The label page: the whole catalog (every TRACKLIST, in order) as one spectrogram, printed
    as text. Time runs down, low frequencies left; characters by rank, so the quietest ~half of
    the cells are air. Catalog numbers mark where each album begins. Written into the root
    README's first code block."""
    W, H = 72, 56
    steps = [(0.46, " "), (0.62, "·"), (0.74, ":"), (0.83, "-"), (0.90, "="), (0.95, "+"), (0.98, "*")]
    studios = sorted(s for s in os.listdir(os.path.join(ROOT, "studios"))
                     if os.path.isfile(os.path.join(ROOT, "studios", s, "TRACKLIST")))
    files, marks, total = [], [], 0.0
    for st in studios:
        marks.append((total, st))
        for slug in tracks(st):
            f = mp3(st, slug)
            files.append(f"file '{f}'")
            total += duration(f)
    with tempfile.TemporaryDirectory() as tmp:
        lst, png = os.path.join(tmp, "list.txt"), os.path.join(tmp, "spec.png")
        open(lst, "w").write("\n".join(files) + "\n")
        ffmpeg("-f", "concat", "-safe", "0", "-i", lst, "-ac", "1", "-ar", "32000", "-lavfi",
               "showspectrumpic=s=512x1024:orientation=horizontal:legend=0:color=intensity:scale=log:fscale=log,format=gray",
               "-frames:v", "1", png)
        raw = subprocess.run(["ffmpeg", "-v", "error", "-i", png, "-vf", f"scale={W}:{H}:flags=area",
                              "-f", "rawvideo", "-pix_fmt", "gray", "-"], capture_output=True).stdout
    vals = sorted(raw)
    cuts = [(vals[min(len(vals) - 1, int(q * len(vals)))], c) for q, c in steps]
    ch = lambda v: next((c for cut, c in cuts if v < cut), "#")
    rowmark = {min(H - 1, int(t / total * H)): st for t, st in marks}
    rows = [f"{rowmark.get(r, ''):>3}  " + "".join(ch(v) for v in raw[r * W:(r + 1) * W]).rstrip() for r in range(H)]
    hms = "%02d:%02d:%05.2f" % (total // 3600, total % 3600 // 60, total % 60)
    art = "\n".join(r.rstrip() for r in rows)
    readme = os.path.join(ROOT, "README.md")
    text = open(readme, encoding="utf-8").read()
    a = text.index("```text\n") + len("```text\n")
    b = re.compile(r"^```$", re.M).search(text, a).start()     # the line that closes the block
    open(readme, "w", encoding="utf-8").write(text[:a] + art + "\n" + text[b:])
    print(f"  README art: {len(files)} tracks, {hms}")


def repo_card():
    """The label cover: the root README's art, 2048×2048 like the album covers."""
    os.makedirs(OUT, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        t = os.path.join(tmp, "label.txt")
        cover_text(None, t, os.path.join(ROOT, "README.md"))
        still(t, os.path.join(OUT, "ffmpeg-music.png"), 2048, 2048)


def main():
    args = sys.argv[1:]
    only = None
    if args[:1] == ["--only"]:
        only, args = args[1], args[2:]
    studios = args or sorted(s for s in os.listdir(os.path.join(ROOT, "studios"))
                             if os.path.isfile(os.path.join(ROOT, "studios", s, "TRACKLIST")))
    steps = {"covers": covers, "stills": stills, "browse": browse, "listen": listen}
    for st in studios:
        for name, fn in steps.items():
            if only in (None, name):
                print(f"{st} {name}…", flush=True)
                fn(st)
    if only in (None, "trailer"):
        print("trailer…", flush=True); trailer(studios)
    if only in (None, "label"):
        print("label…", flush=True); label()
    if only in (None, "covers", "label"):
        repo_card()
    print(f"done → {OUT}")


if __name__ == "__main__":
    main()
