#!/bin/sh
# 401 — Codebook Canon  (Organology I)
#
# Every note, every timbre and the room come from inside libavcodec.
# SCORE  The AAC spectral Huffman codebooks bits1..bits11 (1241 bytes at 0xc0d558): the code
#        length of each symbol, i.e. how surprised the AAC decoder is to meet it (-log2 p).
#        Pitch = surprisal: a 1-bit code (the most probable symbol) is the tonic, rarer
#        symbols climb away from home. The tables' own geometry is the form: books 1-4 are
#        3x3x3x3 crystals, 5-6 concentric bowls (palindromes), 7-8 8x8 gradients,
#        9-10 13x13 staircases, 11 a 17x17 field whose escape column returns as a refrain.
# CANON  Contrapuntal devices are reading conventions:
#        dux        = the table read at 6 bytes/s
#        comes      = the same table one codebook (81 bytes) ahead, inverted (probable = high)
#                     -> paired books have similar contours, so the voices move contrary
#        diminution = the whole table at 4x speed, looped: the piece in miniature, 4 times
# HARMONY Each codebook gets a root (aeolian on A): i i iv iv VI VI VII VII III v i,
#        held by pedal pipes = g723.1's cosine table (one exact cycle, 512 int16) looped at a
#        declared sample rate of f*512 Hz; Chebyshev waveshaping T2,T3 adds the 8' and 5 1/3'
#        ranks as exact harmonics. Melodies are diatonic degrees above the book's root.
# TIMBRE Pulsar synthesis: a fractional impulse train at the note's pitch convolved (afir)
#        with a window table: SBR QMF window (dux), CELT window (comes), MPEG-audio
#        enwindow (diminution). Kick = the cosine table, 3 cycles at 52 Hz, struck on the
#        dux's 1-4 bit codes (the most probable symbols are the downbeats).
# ROOM   Reverb IR = the machine code of ff_aac_decode_ics (the function that reads these
#        codebooks) and aac_decode_frame, read as unsigned 8-bit and faded exponentially.
# FORM   Orchestration follows the books: 1-2 dux+pedal, 3 comes, 4 kick, 5 diminution,
#        11 the voices thin out and the dux finishes alone.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
B=$((0xc0d558)); E=$((0xc0da32)); COS=$((0xcc09f0))
tab() { echo "subfile,,start,$1,end,$2,,:$A"; }
ZOH="aresample=48000:filter_size=1:phase_shift=0"
# ld(6) = codebook index k (0..10) at 6 steps/s, ld(7) = its root degree (digit table, read right to left)
BOOK="st(6,floor(t*6));st(7,gte(ld(6),81)+gte(ld(6),162)+gte(ld(6),243)+gte(ld(6),324)+gte(ld(6),405)+gte(ld(6),486)+gte(ld(6),550)+gte(ld(6),614)+gte(ld(6),783)+gte(ld(6),952));st(6,ld(7));st(7,mod(floor(4266553300/pow(10,ld(6))),10))"
# aeolian degree -> semitones above A
SEM="(floor((12*(DEG+5)+5)/7)-9)"
# fractional impulse train at ld(2) cycles/sample; state: 0 phase, 8 carry; output ld(5)
PULSE="st(0,ld(0)+ld(2));st(3,gte(ld(0),1));st(0,ld(0)-ld(3));st(4,ld(3)*ld(0)/ld(2));st(5,ld(8)+ld(3)*(1-ld(4)));st(8,ld(4))"
BYTE="st(9,round((val(0)+1)*128))"
dux=$(echo $SEM | sed 's/DEG/(ld(7)+ld(9)-4)/')
com=$(echo $SEM | sed 's/DEG/(ld(7)+10-ld(9))/')
dim=$(echo $SEM | sed 's/DEG/(ld(7)+ld(9)-4)/')
# smoothed gate for pedal pipe on root r
pipe() { echo "aloop=-1:512,aresample=48000,atrim=0:207,aeval='$BOOK;st(1,ld(1)+0.00015*(eq(ld(7),$1)-ld(1)));val(0)*ld(1)'"; }
ffmpeg -hide_banner -y \
 -f u8 -ar 6  -ac 1 -i "$(tab $B $E)" \
 -f u8 -ar 6  -ac 1 -i "$(tab $((B+81)) $E)" \
 -f u8 -ar 24 -ac 1 -i "$(tab $B $E)" \
 -f f32le -ar 48000 -ac 1 -i "$(tab $((0xc0a640)) $((0xc0a640+2560)))" \
 -f f32le -ar 48000 -ac 1 -i "$(tab $((0xdc2c40)) $((0xdc2c40+544)))" \
 -f s32le -ar 96000 -ac 1 -i "$(tab $((0xd93e78)) $((0xd93e78+1056)))" \
 -f s16le -ar 28160 -ac 1 -i "$(tab $COS $((COS+1024)))" \
 -f s16le -ar 37581 -ac 1 -i "$(tab $COS $((COS+1024)))" \
 -f s16le -ar 44704 -ac 1 -i "$(tab $COS $((COS+1024)))" \
 -f s16le -ar 50176 -ac 1 -i "$(tab $COS $((COS+1024)))" \
 -f s16le -ar 33488 -ac 1 -i "$(tab $COS $((COS+1024)))" \
 -f s16le -ar 42192 -ac 1 -i "$(tab $COS $((COS+1024)))" \
 -f s16le -ar 26624 -ac 1 -i "$(tab $COS $((COS+1024)))" \
 -f u8 -ar 48000 -ac 1 -i "$(tab $((0x7c38)) $((0x7c38+144000)))" \
 -f u8 -ar 48000 -ac 1 -i "$(tab $((0x9a04)) $((0x9a04+144000)))" \
 -filter_complex "
[0]asplit[i0a][i0b];
[3]aresample=48000,highpass=f=20[ir_qmf];
[4]aresample=48000,highpass=f=20[ir_celt];
[5]aresample=48000,highpass=f=20[ir_enw];

[i0a]$ZOH,aeval='$BYTE;$BOOK;st(2,220*pow(2,$dux/12)/48000);$PULSE;
  st(1,mod(t*6,1)/6);ld(5)*(0.3+0.7*exp(-ld(1)*7))*(1-0.5*gte(ld(6),10)*gte(t,195))'[pdux];
[pdux][ir_qmf]afir=irnorm=1,lowpass=f=3500,volume=16,pan=stereo|c0=0.85*c0|c1=0.4*c0[dux];

[1]$ZOH,aeval='$BYTE;$BOOK;st(2,110*pow(2,$com/12)/48000);$PULSE;
  ld(5)*gte(ld(6),2)*min(1,(t-27)/6)'[pcom];
[pcom][ir_celt]afir=irnorm=1,lowpass=f=2200,volume=16,pan=stereo|c0=0.4*c0|c1=0.85*c0[com];

[2]aloop=loop=3:size=1241,$ZOH,aeval='$BYTE;$BOOK;st(2,440*pow(2,$dim/12)/48000);$PULSE;
  st(1,mod(t*24,1)/24);ld(5)*exp(-ld(1)*50)*gte(ld(6),4)*min(1,(t-54)/20)*(1-gte(ld(6),10)*min(1,(t-158)/30))'[pdim];
[pdim][ir_enw]afir=irnorm=1,highpass=f=500,lowpass=f=4500,volume=0.8,asplit[d1][d2];
 [d2]adelay=83[d2d];[d1][d2d]amerge,pan=stereo|c0=c0|c1=c1[dim];

[6]$(pipe 0)[pA];[7]$(pipe 3)[pD];[8]$(pipe 5)[pF];[9]$(pipe 6)[pG];[10]$(pipe 2)[pC];[11]$(pipe 4)[pE];
[pA][pD][pF][pG][pC][pE]amix=inputs=6:normalize=0,aeval='st(0,val(0)*0.9);ld(0)+0.45*(2*ld(0)*ld(0)-1)+0.2*(4*pow(ld(0),3)-3*ld(0))',
 highpass=f=25,volume=0.25,pan=stereo|c0=c0|c1=c0[pedal];

[12]aloop=loop=2:size=512,aresample=48000,afade=t=out:st=0:d=0.06:curve=exp[ir_kick];
[i0b]$ZOH,aeval='$BYTE;st(6,floor(t*6));st(5,lte(ld(9),4)*not(eq(ld(6),ld(7))));st(7,ld(6));ld(5)*gte(t,40.5)'[kimp];
[kimp][ir_kick]afir=irnorm=-1,volume=0.9,lowpass=f=250,pan=stereo|c0=c0|c1=c0[kick];

[dux][com][dim][pedal]amix=inputs=4:normalize=0,asplit[dry][wet0];
[13]highpass=f=200,lowpass=f=4000,afade=t=out:st=0:d=3:curve=exp[irL];
[14]highpass=f=200,lowpass=f=4000,afade=t=out:st=0:d=3:curve=exp[irR];
[irL][irR]amerge[ir_room];
[wet0]highpass=f=180[wet1];[wet1][ir_room]afir=irnorm=2,volume=0.3[wet];
[dry][wet][kick]amix=inputs=3:normalize=0,volume=2.2,acompressor=threshold=0.25:ratio=2.5:attack=8:release=150,
 alimiter=limit=0.8:level=0,afade=t=in:d=0.3,afade=t=out:st=201:d=6,atrim=0:207
" "$@"
