#!/bin/bash
# Play pieces and sketches live. A .sh piece/sketch runs its single ffmpeg command and
# streams to ffplay; an audio file in sketches/ just plays.
# usage: scripts/play.sh 200            a studio's album, in TRACKLIST order
#        scripts/play.sh 002            any other number/prefix: pieces + sketches in every studio
#        scripts/play.sh 300    a studio as an album (its TRACKLIST, else pieces then sketches)
#        scripts/play.sh sketches       every studio's sketches
#        scripts/play.sh path/to/x.sh   explicit file
#        scripts/play.sh                every piece        -l loop   -s 42 start at 42s
#        scripts/play.sh --bg PATH      play detached, replacing whatever --bg was playing
#        scripts/play.sh --stop         stop the detached player
cd "$(dirname "$0")/.."
PIDFILE=.playing.pid

stop_bg() { [ -f $PIDFILE ] && kill -- -"$(cat $PIDFILE)" 2>/dev/null; rm -f $PIDFILE; }

play_one() {  # $1 file, $2 start seconds
  case "$1" in
    *.sh) sh "$1" -loglevel error -ss "$2" -f nut -c:a pcm_f32le - </dev/null |
            ffplay -hide_banner -loglevel error -nodisp -autoexit -i - ;;
    *.wav|*.mp3|*.flac|*.ogg|*.aiff|*.m4a|*.opus|*.mka|*.mkv|*.nut)
          ffplay -hide_banner -loglevel error -nodisp -autoexit -ss "$2" "$1" ;;
    *) echo "not playable: $1" ;;
  esac
}

playable_in() { find "$1" -maxdepth 1 -type f \( -name '*.sh' -o -name '*.wav' -o -name '*.mp3' -o -name '*.flac' -o -name '*.ogg' -o -name '*.opus' -o -name '*.mka' -o -name '*.aiff' \) | sort; }

case "$1" in
  --stop) stop_bg; exit 0 ;;
  --bg) stop_bg; set -m; play_one "$2" "${3:-0}" >/dev/null 2>&1 </dev/null & echo $! > $PIDFILE; exit 0 ;;
esac

loop=0; ss=0
while getopts "ls:" o; do case $o in l) loop=1;; s) ss=$OPTARG;; esac; done; shift $((OPTIND-1))
files=()
if [ $# -eq 0 ]; then files=(studios/*/pieces/*.sh)
else
  for a in "$@"; do
    [[ $a =~ ^[0-9]{3}$ ]] && [ -d "studios/$a" ] && a="studios/$a"   # a bare studio number is its album
    if [ -f "$a" ]; then files+=("$a")
    elif [ -d "$a" ] && [ -f "$a/TRACKLIST" ]; then   # an album: play its tracklist in order
      while read -r t; do t=${t%%#*}; t=$(echo $t); [ -n "$t" ] && [ -f "$a/pieces/$t" ] && files+=("$a/pieces/$t"); done < "$a/TRACKLIST"
    elif [ -d "$a" ] && [ -d "$a/pieces" ]; then while read -r f; do files+=("$f"); done < <(playable_in "$a/pieces"; playable_in "$a/sketches" 2>/dev/null)
    elif [ -d "$a" ]; then while read -r f; do files+=("$f"); done < <(playable_in "$a")
    elif [ "$a" = sketches ]; then for d in studios/*/sketches; do while read -r f; do files+=("$f"); done < <(playable_in "$d"); done
    else for f in studios/*/pieces/$a* studios/*/sketches/$a*; do [ -f "$f" ] && files+=("$f"); done
    fi
  done
fi
[ ${#files[@]} -eq 0 ] && { echo "nothing matches: $*"; exit 1; }
trap 'kill 0' INT
while :; do
  for p in "${files[@]}"; do
    echo; echo "▶ $p"; [ "${p##*.}" = sh ] && sed -n '2,/^ffmpeg/p' "$p" | grep '^#' | sed 's/^# \{0,1\}/   /'
    play_one "$p" "$ss"
  done
  [ $loop = 1 ] || break
done
