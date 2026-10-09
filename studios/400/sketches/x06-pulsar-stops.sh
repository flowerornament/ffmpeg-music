#!/bin/sh
# Pulsar voice: fractional impulse train (pitch from AAC codebook 5) convolved with a libavcodec table as pulsaret.
# usage: x06 TABLE_OFFSET BYTES FMT DECLARED_RATE out...
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
B=$((0xc0d558+324))
O=$1; N=$2; FMT=$3; RATE=$4; shift 4
ffmpeg -hide_banner -y \
 -f u8 -ar 4 -ac 1 -i "subfile,,start,$B,end,$((B+81)),,:$A" \
 -f $FMT -ar $RATE -ac 1 -i "subfile,,start,$O,end,$((O+N)),,:$A" \
 -filter_complex "
[1]aresample=48000,highpass=f=20[ir];
[0]aresample=48000:filter_size=1:phase_shift=0,aeval='st(9,round((val(0)+1)*128));st(1,floor((12*(ld(9)+1)+5)/7)-2);
 st(2,110*pow(2,ld(1)/12)/48000);st(0,ld(0)+ld(2));st(3,gte(ld(0),1));st(0,ld(0)-ld(3));st(4,ld(3)*ld(0)/ld(2));
 st(5,ld(8)+ld(3)*(1-ld(4)));st(8,ld(4));ld(5)'[imp];
[imp][ir]afir=irnorm=0,highpass=f=30,loudnorm=I=-18:TP=-2,aresample=48000,atrim=0:10" "$@"
