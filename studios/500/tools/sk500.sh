#!/bin/bash
# sketch renderer (not art): sk500.sh a.sh b.sh -> $OUT/name.{wav,png,log} + loudness/band line
# OUT defaults to ./o ; renders in parallel; never touches studios/*/out.
OUT=${OUT:-./o}; mkdir -p "$OUT"; R=$(cd "$(dirname "$0")/../../.." && pwd)
for p in "$@"; do n=$(basename "$p" .sh); o=$OUT/$n
( start=$(date +%s)
if ! timeout 280 sh "$p" -y "$o.wav" >"$o.log" 2>&1 </dev/null; then echo "FAIL $n: $(grep -iE 'error|invalid|unable|out of range|no such|undefined' "$o.log" | head -3 | tr '\n' ' ')"; exit; fi
ffmpeg -hide_banner -loglevel error -y -i "$o.wav" -lavfi "showspectrumpic=s=900x300:legend=0:color=magma:scale=log:fscale=log" "$o.png"
st=$(ffmpeg -hide_banner -i "$o.wav" -af "ebur128=peak=true:framelog=quiet" -f null - 2>&1)
I=$(echo "$st" | awk '/ I:/{print $2}' | tail -1); P=$(echo "$st" | awk '/Peak:/{print $2}' | tail -1)
echo "$n I=$I pk=$P t=$(( $(date +%s)-start ))s $("$R/scripts/analyze.sh" "$o.wav")" ) &
done; wait
