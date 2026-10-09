#!/bin/bash
# studio-100 sketch harness (not art): sk.sh sketch.sh... -> sketches/o/name.{wav,png,stats}
D=$(cd "$(dirname "$0")" && pwd)
for p in "$@"; do n=$(basename "$p" .sh); o="$D/o/$n"; st=$(date +%s)
timeout 600 sh "$p" "$o.wav" >"$o.log" 2>&1 </dev/null || { echo "FAIL $n: $(grep -iE 'error|invalid|unable|range|no such|fail|undefined' "$o.log"|head -3|tr '\n' ' ')"; continue; }
ffmpeg -hide_banner -loglevel error -y -i "$o.wav" -lavfi "showspectrumpic=s=1200x400:legend=0:color=magma:scale=log:fscale=log" "$o.png"; ffmpeg -hide_banner -loglevel error -y -i "$o.wav" -lavfi "showspectrumpic=s=1200x500:legend=0:color=magma:scale=log:fscale=lin:start=20:stop=1500:drange=60" "$o.lo.png"
s=$(ffmpeg -hide_banner -i "$o.wav" -af "ebur128=peak=true:framelog=quiet" -f null - 2>&1)
I=$(echo "$s"|awk '/ I:/{print $2}'|tail -1); P=$(echo "$s"|awk '/Peak:/{print $2}'|tail -1)
d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$o.wav")
echo "$n dur=${d%.*} I=$I peak=$P r=$(( $(date +%s)-st ))s $("$D/../../scripts/analyze.sh" "$o.wav")" | tee "$o.stats"
done
