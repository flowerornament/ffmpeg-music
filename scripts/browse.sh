#!/bin/bash
# Terminal browser for every studio's pieces and sketches (fzf + chafa).
#   enter  play live          ctrl-x  stop             ctrl-r  render (mp3/png/stats)
#   ctrl-j journal            ctrl-o  handoff          ctrl-e  full source
#   ctrl-g refresh list (composers keep adding things)   esc  quit (stops playback)
# Spectrograms render as text by default; FFMPEG_MUSIC_IMG=auto lets chafa use sixel/kitty.
cd "$(dirname "$0")/.."
self=scripts/browse.sh

list() {
  for d in studios/*/; do
    s=$(basename "$d")
    for f in "$d"pieces/*.sh "$d"sketches/*; do
      [ -f "$f" ] || continue
      case "$f" in *.sh|*.wav|*.mp3|*.flac|*.ogg|*.opus|*.mka|*.aiff) ;; *) continue ;; esac
      kind=piece; [[ $f == */sketches/* ]] && kind=sketch
      n=$(basename "$f"); b=${n%.*}
      st=""; [ -f "$d/out/$b.stats" ] && st=$(awk '{for(i=2;i<=4;i++) printf "%s ", $i}' "$d/out/$b.stats")
      title=""; [[ $f == *.sh ]] && title=$(sed -n '2s/^# *//p' "$f" | cut -c1-48)
      printf '%s\t%s  %-6s %-34s %-48s %s\n' "$f" "$s" "$kind" "$b" "$title" "$st"
    done
  done
}

# newest file named $2 anywhere in studio $1 (composers keep renders in different places)
find_art() { find "$1" -maxdepth 3 -name "$2" -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1; }

# render one item in the background, then ask fzf to redraw the preview
bg_render() {  # $1 file  $2 studio  $3 base
  lock="$2/out/$3.rendering"; mkdir -p "$2/out"
  [ -f "$lock" ] && return
  [ "$(ls studios/*/out/*.rendering 2>/dev/null | wc -l)" -ge 3 ] && return   # be kind to the composers' CPUs
  touch "$lock"
  ( set -m; ( if [[ $1 == *.sh ]]; then nice -n 10 scripts/render.sh -f "$1" >/dev/null 2>&1
             else ffmpeg -hide_banner -loglevel error -y -i "$1" \
                    -lavfi "showspectrumpic=s=900x300:legend=0:color=magma:scale=log:fscale=log" "$2/out/$3.png"; fi
             rm -f "$lock"
             [ -n "$FZF_PORT" ] && curl -s -XPOST "localhost:$FZF_PORT" -d 'refresh-preview' >/dev/null ) \
    </dev/null >/dev/null 2>&1 & )
}

# Fit text to the preview width. Prose (piece headers) is reflowed: lines hard-wrapped at
# ~90 columns are rejoined into paragraphs, then wrapped at word boundaries with hanging
# indents ("label  text" lines continue under the text column). Code (`wrap code`) keeps
# its lines and only wraps the overflow, indented. fzf's own wrap breaks mid-word.
wrap() {
  python3 -c '
import sys, re, textwrap
w, mode = int(sys.argv[1]) - 1, sys.argv[2]
lines = sys.stdin.read().rstrip("\n").split("\n")
def lead(l): return len(l) - len(l.lstrip(" "))
def hang(l):  # "label  text" near the margin: continue under the text column
    m = re.search(r"\S {2,}(?=\S)", l[lead(l):]) if lead(l) <= 3 else None
    return lead(l) + m.end() if m and lead(l) + m.end() < 40 else lead(l)
paras = []
if mode == "prose":
    lens = sorted(len(l) for l in lines if l.strip())
    full = lens[len(lens) * 3 // 4] * 0.7 if lens else 0   # "was hard-wrapped" for flush-left prose
    for l in lines:
        p = paras[-1] if paras else None
        cont = p and l.strip() and p["text"].strip() and (
            (lead(l) > 0 and lead(l) == p["hang"] and lead(l) > lead(p["text"])) or   # hanging continuation
            (lead(l) == 0 == p["hang"] and p["last"] >= full))                        # flush-left prose
        if cont:
            p["text"] += " " + l.strip(); p["last"] = len(l)
        else:
            paras.append({"text": l, "hang": hang(l), "last": len(l)})
else:
    paras = [{"text": l, "hang": lead(l) + 2} for l in lines]
for p in paras:
    t, ind = p["text"], p["hang"]
    if ind > w * 0.5: ind = lead(t) + 2
    print(t if len(t) <= w else textwrap.fill(t, width=w, subsequent_indent=" " * ind,
          break_on_hyphens=False, replace_whitespace=False))
' "$1" "${2:-prose}"
}

preview() {
  f=$1; d=$(dirname "$(dirname "$f")"); n=$(basename "$f"); b=${n%.*}
  w=${FZF_PREVIEW_COLUMNS:-80}
  printf '\033[1m%s\033[0m   \033[2m%s\033[0m\n' "$b" "$f"
  stats=$(find_art "$d" "$b.stats"); png=$(find_art "$d" "$b.png")
  [ -n "$stats" ] && cut -d' ' -f2- "$stats" | wrap "$w" code | sed $'s/^/\033[36m/; s/$/\033[0m/'
  if [ -n "$png" ] && [ "$png" -nt "$f" ]; then
    chafa --format="${FFMPEG_MUSIC_IMG:-symbols}" -s "${w}x12" "$png" 2>/dev/null
  else
    log="$d/out/$b.log"
    if [ -f "$d/out/$b.rendering" ]; then printf '\033[33mrendering spectrogram… (preview refreshes when done)\033[0m\n'
    elif [[ $f == *.sh ]] && [ -f "$log" ] && [ "$log" -nt "$f" ] && [ ! -f "$d/out/$b.png" ]; then
      printf '\033[31mrender failed — last log lines:\033[0m\n'; tail -4 "$log" | tr '\r' '\n' | tail -4 | cut -c1-"$w"
    else bg_render "$f" "$d" "$b"; printf '\033[33mrendering spectrogram… (preview refreshes when done)\033[0m\n'
      [ -n "$png" ] && chafa --format="${FFMPEG_MUSIC_IMG:-symbols}" -s "${w}x12" "$png" 2>/dev/null   # stale one meanwhile
    fi
  fi
  if [[ $f == *.sh ]]; then
    echo; sed -n '2,/^ffmpeg/p' "$f" | grep '^#' | sed 's/^# \{0,1\}//' | wrap "$w"
    echo; printf '\033[2m'; sed -n '/^ffmpeg/,$p' "$f" | head -60 | wrap "$w" code; printf '\033[0m'
  fi
}

pager() { [ -f "$1" ] && less -R "$1" || { echo "no ${1##*/} yet"; sleep 1; }; }
studio_of() { dirname "$(dirname "$1")"; }

case "$1" in
  --list) list; exit ;;
  --preview) preview "$2"; exit ;;
  --journal) pager "$(studio_of "$2")/JOURNAL.md"; exit ;;
  --handoff) pager "$(studio_of "$2")/HANDOFF.md"; exit ;;
  --render) [[ $2 == *.sh ]] && scripts/render.sh -f "$2"; printf '\n(press enter)'; read -r; exit ;;
esac

trap 'scripts/play.sh --stop; rm -f studios/*/out/*.rendering' EXIT
list | fzf --listen --ansi --delimiter='\t' --with-nth=2 --no-sort --layout=reverse \
  --prompt='ffmpeg-music ▸ ' \
  --header='enter play · ^x stop · ^r render · ^j journal · ^o handoff · ^e source · ^g refresh · esc quit' \
  --preview="$self --preview {1}" --preview-window='right,60%,nowrap' \
  --bind="enter:execute-silent(scripts/play.sh --bg {1})" \
  --bind="ctrl-x:execute-silent(scripts/play.sh --stop)" \
  --bind="ctrl-r:execute($self --render {1})+reload($self --list)" \
  --bind="ctrl-j:execute($self --journal {1})" \
  --bind="ctrl-o:execute($self --handoff {1})" \
  --bind="ctrl-e:execute(less {1})" \
  --bind="ctrl-g:reload($self --list)"
