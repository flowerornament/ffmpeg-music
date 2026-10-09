#!/bin/sh
# 105 — Snow                                             (studio 100 · RASTRUM)
#
# A chorale sung four times, each time deeper in snow.
# The score is a magnitude image on the harmonic raster (sample_rate 20025, 32768 rows per
# ear: row 360 = A2 = 110 Hz; hann, overlap 0.75, four columns per bar of 3.27 s). Twelve bars
# of just-intonation chorale (Am F Dm E | Am C G E | F Dm E A), four voices, each folded into
# its own register window so the voice leading is automatic, each tone with four harmonics.
# Before it is heard, the picture of each statement is passed through a real video codec
# inside the graph: uspp encodes and decodes it with a real libavcodec encoder. This is
# generation loss: statement n is JPEG-encoded and decoded n-1 times (uspp with codec=mjpeg,
# qp 20, 26, 31), the coda four times -- Lucier's room, with a codec for the room. The image
# is LINEAR magnitude, so the codec's errors are audible amplitude: each note snaps to the
# 8x8 DCT block (two bars), grows faint ghost rows one to three rows (0.3-0.9 Hz) away and
# begins to beat; chords bleed into their neighbours. The ears are compressed separately with
# different numbers of shifted passes, so the stereo field is two encoders disagreeing.
# Coda (bars 48-55): the final A major chord held, and the phase goes through JPEG too.
W=224
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
BAR="min(floor(X/4),59)"
# roots as ratios to A:  Am F Dm E | Am C G E | F Dm E A  (bars past 47 hold the last A)
RT="if(eq(ld(0),1)+eq(ld(0),8),1.6,if(eq(ld(0),2)+eq(ld(0),9),1.33333333,if(eq(ld(0),3)+eq(ld(0),7)+eq(ld(0),10),1.5,if(eq(ld(0),5),1.2,if(eq(ld(0),6),1.8,1)))))"
TH="if(eq(ld(0),0)+eq(ld(0),2)+eq(ld(0),4)+eq(ld(0),9),1.2,1.25)"
FOLD="round(360*_R_*pow(2,ceil(log(_L_/(360*_R_))/log(2))))"
TONE="st(4,_ROW_);(eq(mod($K,ld(4)),0)*between($K,ld(4),12*ld(4))*pow($K/ld(4),-1.45))"
HEAD="st(0,if(gte($BAR,48),11,mod($BAR,12)));st(1,$RT);st(2,$TH)"
VB="${TONE//_ROW_/${FOLD//_R_/ld(1)}}"; VB="${VB//_L_/180}"
VT="${TONE//_ROW_/${FOLD//_R_/(ld(1)*1.5)}}"; VT="${VT//_L_/400}"
VA="${TONE//_ROW_/${FOLD//_R_/(ld(1)*ld(2))}}"; VA="${VA//_L_/540}"
VS="${TONE//_ROW_/${FOLD//_R_/(ld(1)*2)}}"; VS="${VS//_L_/760}"
SUB="eq($K,round(${FOLD//_R_/ld(1)}/2))"; SUB="${SUB//_L_/180}"
# swell in and out of each statement; the coda fades over its 8 bars
ENV="(min(1,mod(X,48)/6+0.35)*if(gte($BAR,48),1-0.6*(X-192)/32,1))"
MAG="$HEAD;st(9,(($VB)+0.8*($VT)+0.8*($VA)+0.9*($VS)+0.7*$SUB)*$ENV);min(255,180*ld(9))"
PHA="255*mod($K*X/4+mod(sin($K*12.9898+$LEFT*gt($K,500)*0.4)*43758.5453,1),1)"
SS="spectrumsynth=sample_rate=20025:channels=2:slide=fullframe:scale=lin:win_func=hann:overlap=0.75"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$MAG',split=5[u0][u1][u2][u3][u4];
[u0]crop=48:65536:0:0[v0];
[u1]crop=48:65536:48:0,split[t1][b1];[t1]crop=48:32768:0:0,format=yuvj444p,uspp=quality=2:qp=20:codec=mjpeg,format=gray[t1o];[b1]crop=48:32768:0:32768,format=yuvj444p,uspp=quality=1:qp=20:codec=mjpeg,format=gray[b1o];[t1o][b1o]vstack[v1];
[u2]crop=48:65536:96:0,split[t2][b2];[t2]crop=48:32768:0:0,format=yuvj444p,uspp=quality=2:qp=26:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=2:qp=26:codec=mjpeg,format=gray[t2o];[b2]crop=48:32768:0:32768,format=yuvj444p,uspp=quality=1:qp=26:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=1:qp=26:codec=mjpeg,format=gray[b2o];[t2o][b2o]vstack[v2];
[u3]crop=48:65536:144:0,split[t3][b3];[t3]crop=48:32768:0:0,format=yuvj444p,uspp=quality=2:qp=31:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=2:qp=31:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=2:qp=31:codec=mjpeg,format=gray[t3o];[b3]crop=48:32768:0:32768,format=yuvj444p,uspp=quality=1:qp=31:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=1:qp=31:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=1:qp=31:codec=mjpeg,format=gray[b3o];[t3o][b3o]vstack[v3];
[u4]crop=32:65536:192:0,split[t4][b4];[t4]crop=32:32768:0:0,format=yuvj444p,uspp=quality=2:qp=28:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=2:qp=28:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=2:qp=28:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=2:qp=28:codec=mjpeg,format=gray[t4o];[b4]crop=32:32768:0:32768,format=yuvj444p,uspp=quality=1:qp=28:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=1:qp=28:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=1:qp=28:codec=mjpeg,format=gray,format=yuvj444p,uspp=quality=1:qp=28:codec=mjpeg,format=gray[b4o];[t4o][b4o]vstack[v4];
[v0][v1][v2][v3][v4]hstack=5[m];
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$PHA',split[pa][pb];
[pa]crop=192:65536:0:0[pa1];[pb]crop=32:65536:192:0,split[pt][pq];[pt]crop=32:32768:0:0,format=yuvj444p,uspp=quality=1:qp=24:codec=mjpeg,format=gray[pt1];[pq]crop=32:32768:0:32768,format=yuvj444p,uspp=quality=1:qp=24:codec=mjpeg,format=gray[pq1];[pt1][pq1]vstack[pb1];[pa1][pb1]hstack[p];
[m][p]$SS,aresample=48000,volume=0.2,highpass=f=20,asplit[dry][w0];
aevalsrc=d=5:s=48000:exprs='(random(0)*2-1)*exp(-t*1.1)|(random(1)*2-1)*exp(-t*1.1)',lowpass=f=5000[ir];
[w0]highpass=f=250[w1];[w1][ir]afir=dry=0:wet=1[rev];
[dry][rev]amix=inputs=2:weights=1 0.25:normalize=0,alimiter=limit=0.79:level=0" "$@"
