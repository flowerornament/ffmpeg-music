#!/bin/sh
# Download FFmpeg's documentation as plain text into docs/ffmpeg/ (reference for composers;
# not committed). Needs curl and pandoc.
cd "$(dirname "$0")/.." && mkdir -p docs/ffmpeg && cd docs/ffmpeg || exit 1
for d in ffmpeg ffmpeg-filters ffmpeg-codecs ffmpeg-formats ffmpeg-protocols ffmpeg-utils \
         ffmpeg-bitstream-filters ffmpeg-devices ffmpeg-resampler ffmpeg-scaler; do
  curl -sfL "https://ffmpeg.org/$d.html" -o "$d.html" &&
    pandoc -f html -t plain --wrap=none "$d.html" -o "$d.txt" && rm -f "$d.html" && echo "$d"
done
