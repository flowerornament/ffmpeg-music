#!/bin/bash
# Render harness (NOT part of the art). Each studios/*/pieces/*.sh holds exactly one ffmpeg
# command ending in "$@" (output args supplied by the caller). This script runs it, then derives an mp3,
# a spectrogram and loudness stats so a composer without ears can judge the result.
# Output lands beside the pieces folder: X/pieces/N.sh -> X/out/N.*
# usage: scripts/render.sh [-f] [paths...]   e.g. scripts/render.sh studios/300/pieces/3*.sh   (-f re-renders)
cd "$(dirname "$0")/.."
force=0; [ "$1" = "-f" ] && { force=1; shift; }
pat=("${@:-studios/*/pieces/*.sh}")
render_one() {
  p="$1"; force="$2"; n=$(basename "$p" .sh); od="$(dirname "$p")/../out"; mkdir -p "$od"; o="$od/$n"
  [ "$force" = 0 ] && [ -f "$o.mp3" ] && [ "$o.mp3" -nt "$p" ] && exit 0
  start=$(date +%s)
  if ! timeout 300 sh "$p" "$o.wav" >"$o.log" 2>&1 </dev/null; then echo "FAIL $n: $(grep -iE 'error|invalid|unable|out of range|no such' "$o.log" | head -2 | tr '\n' ' ')"; exit 0; fi
  [ -s "$o.wav" ] || { echo "FAIL $n: no output"; exit 0; }
  ffmpeg -hide_banner -loglevel error -y -i "$o.wav" -ac 2 -c:a libmp3lame -q:a 3 "$o.mp3"
  ffmpeg -hide_banner -loglevel error -y -i "$o.wav" -lavfi "showspectrumpic=s=900x300:legend=0:color=magma:scale=log:fscale=log" "$o.png"
  stats=$(ffmpeg -hide_banner -i "$o.wav" -af "ebur128=peak=true:framelog=quiet" -f null - 2>&1)
  I=$(echo "$stats" | awk '/ I:/{print $2}' | tail -1); P=$(echo "$stats" | awk '/Peak:/{print $2}' | tail -1)
  LRA=$(echo "$stats" | awk '/ LRA:/{print $2}' | tail -1)
  d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$o.wav")
  echo "$n dur=${d%.*}s I=${I}LUFS peak=${P}dB LRA=${LRA} render=$(( $(date +%s)-start ))s $(scripts/analyze.sh "$o.wav")" | tee "$o.stats"
  rm -f "$o.wav"
}
export -f render_one
for p in ${pat[@]}; do echo "$p"; done | xargs -P 8 -I{} bash -c 'render_one "$@"' _ {} $force
