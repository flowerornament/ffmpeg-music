#!/bin/sh
# 305 — Damper (PHI No. 5)
# An arpeggio drawn as spectrum images, one note per sixteenth, photographed by video codecs
# inside this same command (loopback decoders, -dec) before it is resynthesized.
#  the pedal  libx264 at quantizer 51 cannot afford to erase what is no longer there: a P-frame
#             whose residual quantizes to nothing is skipped and the old picture stays. So
#             notes ring on — until the next keyframe repaints the picture. Forced keyframes are
#             the damper: the force_key_frames expression is the pedalling. The same starvation
#             makes the codec drop notes it cannot afford to draw: it edits the arpeggio.
#  exposure   the image brightness before the codec (undone after) decides how starved it is:
#             dim = sparse notes and long pedal (ghosts), bright = every note, crisp.
#  two hands  left ear: pedal changed on beat 1 of every bar; right ear: pedal changed at chord
#             changes (every 4 bars) and on the "and" of beat 2 — the two pianists hold different notes, so the stereo field shimmers.
#             Centre: mjpeg (stills, no memory) — the arpeggio as written, quietly.
#  harmony    just intonation on the FFT grid (bins = harmonics of 11.71875 Hz, tonic 24), five
#             voices packed bass|v1|v2|v3|v4; the arpeggiator plays index mod(3s,5) = 0,3,1,4,2 -> v1, v4,
#             v2, v1 up an octave, v3 and flips octave every 5 steps against the 16-step bar (Barbieri);
#             the bass is struck on the beats. 117.19 bpm, a sixteenth = 6 frames.
#  form       dark -> crisp -> washed -> dark; chords change every 4 bars.
F=46.875
CH="st(9,floor(N/64));if(eq(ld(9),0),0624303645,if(eq(ld(9),1),0520303640,if(eq(ld(9),2),0824324048,if(eq(ld(9),3),0927364554,
if(eq(ld(9),4),0624303645,if(eq(ld(9),5),0728354249,if(eq(ld(9),6),0520253040,if(eq(ld(9),7),0927364563,
if(eq(ld(9),8),0824324056,if(eq(ld(9),9),0728354249,if(eq(ld(9),10),0520304050,if(eq(ld(9),11),0927364563,
if(eq(ld(9),12),0624303645,if(eq(ld(9),13),0824324048,if(eq(ld(9),14),0927364563,if(eq(ld(9),15),0624303648,0624303648))))))))))))))))"
ARP="st(0,H-1-Y);st(8,$CH);st(2,mod(3*N,5));
st(3,if(eq(ld(2),0),mod(floor(ld(8)/1000000),100),if(eq(ld(2),1),mod(floor(ld(8)/10000),100),if(eq(ld(2),2),mod(floor(ld(8)/100),100),
 if(eq(ld(2),3),mod(ld(8),100),2*mod(floor(ld(8)/1000000),100)))))*if(mod(floor(N/5),2),2,1));
st(1,mod(floor(ld(8)/100000000),100)*eq(mod(N,4),0));
st(6,0);st(7,1);while(lte(ld(7),7),st(6,ld(6)+(exp(-pow((ld(0)-ld(3)*ld(7))/1.0,2))+3*exp(-pow((ld(0)-ld(1)*ld(7))/1.0,2)))/ld(7));st(7,ld(7)+1));
min(255,220*ld(6))"
# log2 exposure: dark (-3.5) -> crisp (0, 50-95 s) -> washed (-2.5, 120 s) -> dark (-5, 140 s)
LE="if(lt(T,50),-3.5+3.5*T/50,if(lt(T,95),0,if(lt(T,120),-2.5*(T-95)/25,-2.5-2.5*clip((T-120)/20,0,1))))"
PICK="p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*gt(p(X,Y),4)*0.1/pow(2,$LE)"
PHASE="255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)"
SYN="spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=32x2048:r=$F/6:d=147,format=gray,geq=lum='$ARP',fps=$F,geq=lum='min(255,p(X,Y)*pow(2,$LE))',split=3[v1][v2][v3];
[v1]format=yuv420p[x1];[v2]format=yuv420p[x2];[v3]format=yuvj420p[j]" \
 -map "[x1]" -c:v libx264 -qp 51 -bf 0 -sc_threshold 0 -g 100000 -force_key_frames "expr:eq(mod(n,96),0)" -f null - \
 -map "[x2]" -c:v libx264 -qp 51 -bf 0 -sc_threshold 0 -g 100000 -force_key_frames "expr:eq(mod(n,384),0)+eq(mod(n,96),36)" -f null - \
 -map "[j]" -c:v mjpeg -q:v 20 -f null - \
 -dec 0:0 -dec 1:0 -dec 2:0 -filter_complex "
[dec:0]fps=$F,format=gray,crop=1:2048:16:0,pad=1:2049:0:1,geq=lum='$PICK'[mL];
[dec:1]fps=$F,format=gray,crop=1:2048:16:0,pad=1:2049:0:1,geq=lum='$PICK'[mR];
[dec:2]fps=$F,format=gray,crop=1:2048:16:0,pad=1:2049:0:1,geq=lum='$PICK'[mC];
color=c=black:s=1x2049:r=$F:d=147,format=gray,geq=lum='$PHASE',split=3[pL][pR][pC];
[mL][pL]$SYN[l];[mR][pR]$SYN[r];[mC][pC]$SYN,asplit[c1][c2];
[l][c1]amix=inputs=2:weights=1 0.35:normalize=0[l2];[r][c2]amix=inputs=2:weights=1 0.35:normalize=0[r2];
[l2][r2]join=inputs=2:channel_layout=stereo,atrim=0:146,asplit[dry][w];
aevalsrc=d=4:s=48000:exprs='(random(0)*2-1)*exp(-t*1.5)|(random(1)*2-1)*exp(-t*1.5)',lowpass=f=7000[ir];
[w]highpass=f=150[w2];[w2][ir]afir=dry=1:wet=1[wet];
[dry][wet]amix=inputs=2:weights=1 0.25:normalize=0,highpass=f=25,
 acompressor=threshold=0.12:ratio=2.5:attack=15:release=250,volume=2.4,alimiter=limit=0.89:level=0,
 afade=t=in:d=1,afade=t=out:st=141:d=5[out]" -map "[out]" "$@"
