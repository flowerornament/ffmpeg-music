#!/bin/sh
# 408 — Sygyt  (Organology VIII)
#
# Throat singing from a telephone codec, whistling the AAC codebooks.
# VOICES Each singer is a rank of GSM 06.10 frames decoded by libavcodec's gsm decoder,
#        all at one declared sample rate so their glottal pulses stay in phase: a drone.
#        Each frame K4..K13 has a broad first formant and a doubled, 20 Hz-narrow
#        resonance on harmonic k (designed at 8 kHz where the pulse rate is 200 Hz, so it
#        lands on harmonic k at any rate). Only one is open at a time, and that harmonic
#        whistles 17-26 dB above its neighbours, as in Tuvan sygyt. Moving between
#        frames moves the whistle; the drone underneath never breaks.
# SCORE  Which frame is open is read in place, one byte per second, from libavcodec's
#        AAC Huffman codebooks: code length = harmonic number (1-3 = whistle rests).
#          singer 1, drone A2 (110 Hz): books 5 and 6, the concentric bowls; each row
#                    descends toward the 4th harmonic and climbs back out
#          singer 2, drone E3 (165 Hz, enters 0:40): books 7 and 8, rising 8x8 rows
#          kargyraa: a GSM 'a' on A1 with one pulse per 80 samples; the decoder's frame
#                    clock adds a growl an octave further down
#        Every whistle is a harmonic of 55 Hz, so the two singers share one series:
#        A's 6th = E's 4th (660 Hz), A's 12th = E's 8th, and the 7th and 11th bend it.
# ROOM   libavcodec machine code as a 4 s reverb, a different stretch for each ear.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
B=$((0xc0d558))
K4="038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K5="1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K6="1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K7="1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K8="1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K9="139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K10="2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K11="2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K12="2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K13="2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
DRONE="0noHIRpQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc0noHIRpQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc0noHIRpQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
GROWL="0vZMV5pQCHccccccUAA4444441AIdxxxxxxQADjjjjjj0vZMV5pQCHccccccUAA4444441AIdxxxxxxQADjjjjjj0vZMV5pQCHccccccUAA4444441AIdxxxxxxQADjjjjjj"
mov() { echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$4\\:ch_layout=mono'"; }
ZOH="aresample=48000:filter_size=1:phase_shift=0"
# pipe FRAME RATE LEN : one GSM frame, decoded, steady copy looped, LEN seconds
pipe() { echo "amovie='data\\:application/octet-stream;base64,$1':f=gsm:format_opts='sample_rate=$2',asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB,aresample=48000,atrim=0:$3,aformat=channel_layouts=mono"; }
# gate K : open the pipe (channel 0) while the codebook byte (channel 1) equals K, 40 ms glide
gate() { echo "amerge,aeval='st(1,ld(1)+0.0005*(eq(round((val(1)+1)*128),$1)-ld(1)));val(0)*ld(1)':channel_layout=mono"; }
# singer PREFIX RATE LEN CODEBOOK_LABEL_PREFIX : 10 gated whistle pipes + drone, summed
singer() {
  for k in 4 5 6 7 8 9 10 11 12 13; do eval "f=\$K$k"; echo "$(pipe $f $2 $3)[$1p$k];[$1p$k][$4$k]$(gate $k)[$1g$k];"; done
  echo "$(pipe $DRONE $2 $3),volume=0.35[$1dr];"
  echo "[$1g4][$1g5][$1g6][$1g7][$1g8][$1g9][$1g10][$1g11][$1g12][$1g13][$1dr]amix=inputs=11:normalize=0[$1];"
}
ffmpeg -hide_banner -y \
 -f u8 -ar 1 -ac 1 -i "subfile,,start,$((B+324)),end,$((B+486)),,:$A" \
 -f u8 -ar 1 -ac 1 -i "subfile,,start,$((B+486)),end,$((B+614)),,:$A" \
 -filter_complex "
[0]$ZOH,aformat=channel_layouts=mono,asplit=10[a4][a5][a6][a7][a8][a9][a10][a11][a12][a13];
[1]$ZOH,aformat=channel_layouts=mono,asplit=10[e4][e5][e6][e7][e8][e9][e10][e11][e12][e13];
$(singer s1 4400 162 a)
$(singer s2 6600 128 e)
[s1]afade=t=in:d=3,afade=t=out:st=156:d=6,volume=1.0,adelay=10000:all=1,pan=stereo|c0=0.75*c0|c1=0.45*c0[S1];
[s2]afade=t=in:d=3,afade=t=out:st=122:d=6,volume=0.8,adelay=40000:all=1,pan=stereo|c0=0.45*c0|c1=0.75*c0[S2];
$(pipe $GROWL 4400 178),afade=t=in:d=6,afade=t=out:st=168:d=10,volume=1.1,pan=stereo|c0=c0|c1=c0[G];
[S1][S2][G]amix=inputs=3:normalize=0:duration=longest,highpass=f=40,asplit[dry][w0];
$(mov 0x400000 192000 u8 48000),highpass=f=150,lowpass=f=3500,afade=t=out:st=0:d=4:curve=exp[irL];
$(mov 0x480000 192000 u8 48000),highpass=f=150,lowpass=f=3500,afade=t=out:st=0:d=4:curve=exp[irR];
[irL][irR]amerge[ir];[w0][ir]afir=irnorm=2,volume=0.4[wet];
[dry][wet]amix=inputs=2:normalize=0,volume=0.5,acompressor=threshold=0.3:ratio=2:attack=10:release=200,
 alimiter=limit=0.8:level=0,atrim=0:184,afade=t=out:st=178:d=6
" "$@"
