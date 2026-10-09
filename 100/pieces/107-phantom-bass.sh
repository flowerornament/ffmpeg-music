#!/bin/sh
# 107 — Phantom Bass                                     (studio 100 · RASTRUM)
#
# A bass line and its chords that no loudspeaker plays.
# On the raster (sample_rate 28160, 32768 rows per ear, row = 0.4297 Hz; hann, overlap 0.75,
# a column is a quarter bar) a set of equally spaced rows a + j*d has the periodicity -- the
# residue pitch -- of its spacing d, wherever a sits. So each "note" here is twelve partials
# spaced d rows apart, placed far above the pitch they imply (the root complex around
# 16-27 x d, the upper voice -- a twelfth above -- around 2-4 kHz). Then the complex is split
# between the ears: odd partials left, even partials right. Each ear alone hears a spacing of
# 2d, a pitch an octave higher; the bass d exists only where the two ears meet (dichotic
# residue pitch, Houtsma & Goldstein). On speakers the partials sum in the room and the bass
# is a residue in the air instead of in the head.
# The progression A F C G | A D F E | A moves the spacing d (8 bars each). Inside each section
# the whole complex is slid upward by a shift s (de Boer): the partials stop being harmonics,
# the phantom pitch bends a little and grows ambiguous, then settles as s returns to 0.
# In the last section the ghost becomes body: the real fundamental rows fade in underneath.
W=304
F=0.4296875
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
SEC="min(floor(X/32),8)"
U="(mod(X,32)/32)"
SEMI="(0-4*eq(ld(0),1)+3*eq(ld(0),2)-2*eq(ld(0),3)+5*eq(ld(0),5)-4*eq(ld(0),6)-5*eq(ld(0),7))"
D1="(55*pow(2,ld(1)/12)/$F)"
SH="(0.42*pow(sin(PI*$U),2)*lt(ld(0),8))"
ENVS="(min(1,$U*6)*if(eq(ld(0),8),max(0,1-(X-256)/48),1))"
# one dichotic complex: spacing _D_, lowest partial n0=_N_, 12 partials, gaussian over j
CX="st(2,_D_);st(3,ld(2)*(_N_+$SH));st(4,($K-ld(3))/ld(2));st(5,round(ld(4)));if(between(ld(5),0,11)*eq(mod(ld(5)+_N_,2),$LEFT),max(0,1-abs($K-ld(3)-ld(5)*ld(2)))*exp(-pow((ld(5)-5.5)/4,2)),0)"
LOW="${CX//_D_/$D1}"; LOW="${LOW//_N_/16}"
HIGH="${CX//_D_/$D1*3}"; HIGH="${HIGH//_N_/12}"
BODY="(eq($K,round($D1))+0.5*eq($K,round(2*$D1)))*eq(ld(0),8)*min(1,(X-256)/16)"
MAG="st(0,$SEC);st(1,$SEMI);st(9,(0.9*($LOW)+0.45*($HIGH)+1.2*$BODY)*$ENVS);if(gt(ld(9),0.0005),255+2.125*(-12+8.6859*log(ld(9))),0)"
PHA="255*mod($K*X/4+mod(sin($K*78.233+$LEFT*1.7)*43758.5453,1),1)"
SS="spectrumsynth=sample_rate=28160:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$MAG'[m];
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$PHA'[p];
[m][p]$SS,aresample=48000,asplit[dry][w0];
aevalsrc=d=6:s=48000:exprs='(random(0)*2-1)*exp(-t*0.9)|(random(1)*2-1)*exp(-t*0.9)',lowpass=f=6000[ir];
[w0][ir]afir=dry=0:wet=1[rev];
[dry][rev]amix=inputs=2:weights=1 0.3:normalize=0,alimiter=limit=0.79:level=0,afade=t=in:d=3" "$@"
