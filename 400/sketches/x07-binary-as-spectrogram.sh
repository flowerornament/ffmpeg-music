#!/bin/sh
# libavcodec's table region read as rawvideo: each 513-byte row = one FFT magnitude frame (horizontal orientation).
# phase = the same bytes one row later.  hop 256 @48k -> 187.5 rows/s
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
S=$((0xc0d000))
ffmpeg -hide_banner -y \
 -f rawvideo -pix_fmt gray -s 513x1 -r 187.5 -i "subfile,,start,$S,end,$((S+513*187*20)),,:$A" \
 -f rawvideo -pix_fmt gray -s 513x1 -r 187.5 -i "subfile,,start,$((S+513)),end,$((S+513*187*20+513)),,:$A" \
 -filter_complex "[0]format=gray[m];[1]format=gray[p];[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=fullframe:orientation=horizontal:scale=lin:win_func=hann:overlap=0.75,highpass=f=25,loudnorm=I=-18:TP=-2,aresample=48000" "$@"
