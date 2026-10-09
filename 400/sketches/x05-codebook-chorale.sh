#!/bin/sh
# AAC Huffman codebooks 1,2,5,6 (81 code lengths each) as a 4-voice chorale, 2 chords/s.
# code length (bits) -> scale degree (dorian), voices in separate registers.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
B=$((0xc0d558))
ZOH="aresample=48000:filter_size=1:phase_shift=0"
OSC="st(1,floor((12*(ld(9)+1)+5)/7)-2);st(0,mod(ld(0)+BASE*pow(2,ld(1)/12)/48000,1));sin(2*PI*ld(0))+0.3*sin(4*PI*ld(0))"
ffmpeg -hide_banner -y \
 -f u8 -ar 2 -ac 1 -i "subfile,,start,$B,end,$((B+81)),,:$A" \
 -f u8 -ar 2 -ac 1 -i "subfile,,start,$((B+81)),end,$((B+162)),,:$A" \
 -f u8 -ar 2 -ac 1 -i "subfile,,start,$((B+324)),end,$((B+405)),,:$A" \
 -f u8 -ar 2 -ac 1 -i "subfile,,start,$((B+405)),end,$((B+486)),,:$A" \
 -filter_complex "
[0]$ZOH,aeval='st(9,round((val(0)+1)*128));$(echo $OSC|sed s/BASE/55/)'[v0];
[1]$ZOH,aeval='st(9,round((val(0)+1)*128));$(echo $OSC|sed s/BASE/110/)'[v1];
[2]$ZOH,aeval='st(9,round((val(0)+1)*128));$(echo $OSC|sed s/BASE/220/)'[v2];
[3]$ZOH,aeval='st(9,round((val(0)+1)*128));$(echo $OSC|sed s/BASE/220/)'[v3];
[v0][v1][v2][v3]amix=inputs=4,volume=0.6" "$@"
