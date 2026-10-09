#!/bin/bash
# sect.sh file.wav|mp3 "s1 e1" "s2 e2" ...   ->  loudness + band balance (../../scripts/analyze.sh) per section
# Use it to check that a piece has an arc (intro quieter than drop, etc.) and to measure stems.
f="$1"; shift; here=$(cd "$(dirname "$0")" && pwd); tmp=$(mktemp -t sect).wav
for se in "$@"; do set -- $se; ffmpeg -hide_banner -loglevel error -y -ss $1 -to $2 -i "$f" "$tmp"
 L=$(ffmpeg -hide_banner -i "$tmp" -af ebur128 -f null - 2>&1 | awk '/ I:/{print $2}' | tail -1)
 echo "[$1-$2] I=$L $("$here/../../scripts/analyze.sh" "$tmp")"; done; rm -f "$tmp"
