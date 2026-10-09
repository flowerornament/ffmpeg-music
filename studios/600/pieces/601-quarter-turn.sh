#!/bin/sh
# 601 — QUARTER-TURN
# Studio 600 (Claude). Genre: Quarter-Turn. 125 bpm, D (75 Hz) harmonic series, 24 phrases of 4 bars.
#
# The whole piece is one moving picture S (384 x 513, gray16) of the time-frequency plane,
# drawn by geq, re-drawn every 4 bars, and read by spectrumsynth in two ways:
#   A  = S as it stands: columns are time (20 ms), rows are frequency (12.5 Hz).  -> harmony
#   R  = S rotated by theta about (192,192) in (col,row) space.                   -> groove
# The geometry is the score. At sample rate 12800 with hop 256, six columns are a 16th at 125 bpm
# and six rows are 75 Hz. So harmonic p of 75 Hz is the same row as 16th-step p. A quarter-turn
# sends partial p to step 64-p and "when in the phrase" to "how high":
#   chord 4:5:6 x m (triads on harmonic m, with octaves)  ->  the rim/fill pattern of the phrase
#   partials p%4==0 lit only at the phrase start           ->  kick on every beat (low = early)
#   partials p%8==4 flickering in the first half           ->  snare on 2 and 4 (flicker = noise)
#   partials p%4==2 swelling at the phrase end             ->  offbeat hats (late = bright)
#   bass partials 1, 2                                     ->  the pickup into the next phrase
# The riser is the rotation: over four phrases the angle sweeps 0 -> 90 degrees, every partial
# bends into an accelerating glissando, and at 90 degrees they stand up into the beat. A is heard through a horizontal blur (drum shadows
# become swells) and is ducked by R. "Air" is the rotated picture read at 25.6 kHz: the same
# groove twice as fast and an octave up, high-passed.
# Progression (root harmonic per 2 phrases): 1 5 7 | 1 5 7 3 | 9 | 1 5 3 1  =  D F# C(7th) A E.
PH=7.68
PROG=135193751751
TRI=282578801202544    # bit r set for r in {4,5,6,8,10,12,16,20,24,32,40,48}: 4:5:6 and its octaves
M="floor(T/$PH+0.01)"     # phrase index inside geq (T = frame time, so it holds at any frame rate)
# rotation (quarter-turns), continuous: intro 0, riser 0->1 over 4 phrases, drop 1, breakdown 0 then 0->1, out 1->1/3
F="(T+X/100)/$PH"      # continuous phrase position of an output pixel (10 ms columns): the angle moves inside a picture
TH="PI/2*if(lt($F,2),0,if(lt($F,6),($F-2)/4,if(lt($F,14),1,if(lt($F,15),0,if(lt($F,16),$F-15,if(lt($F,22),1,1-($F-22)/3))))))"
SCORE="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 st(3,mod(floor($PROG/pow(10,floor($M/2))),10));st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.5)*exp(-pow((X-6+0.7*ld(2))/1.5,2))+eq(ld(2),0)*0.6*exp(-X/12))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),4)*between(X,20,200)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.5)*7000
+eq(mod(ld(1),4),2)*lte(ld(2),1+gte($M,16))*gte(X,220)*pow((X-220)/163,2)*9000
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2500
+eq(ld(2),0)*between(ld(1),1,2)*(4000+2000*gte($M,16))"
# rotated reading at fft 512: output col u (10 ms), bin v (25 Hz) -> t'=u/2, f'=2v -> inverse rotation
ROT="st(5,$TH);st(8,X/2-192);st(9,2*(512-Y)-192);
 st(6,ld(8)*cos(ld(5))+ld(9)*sin(ld(5))+192);st(7,-ld(8)*sin(ld(5))+ld(9)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(2*ld(6),512-ld(7))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,24)*0.15*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
PW2="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,12)*0.25*mod(sin((H-1-Y)*17.3)*2375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
n="floor(t/$PH)"
D=184.32
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$SCORE',split[s1][s2];
[s1]gblur=sigma=10:sigmaV=0.01,split[a1][a2];
[s2]scale=768x513:flags=bilinear,geq=lum='$ROT',crop=768:257:0:256,split[r][hh];
[hh]fps=25600/98304,split[h1][h2];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[pa];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PW'[pw];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[pr];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PW'[ph1];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PW2'[ph2];
[a1][pa]spectrumsynth=sample_rate=12800:$SS[AL];
[a2][pw]spectrumsynth=sample_rate=12800:$SS[AR];
[r][pr]spectrumsynth=sample_rate=12800:$SS,aresample=48000,
 volume='if(lt(t,2*$PH),0,if(lt(t,6*$PH),0.18+0.06*($n-2),if(lt(t,14*$PH),1,if(lt(t,15*$PH),0,if(lt(t,16*$PH),0.25,if(lt(t,22*$PH),1,0.5))))))*(1-between(t,6*$PH-0.48,6*$PH-0.001))':eval=frame,asplit[R][key];
[h1][ph1]spectrumsynth=sample_rate=25600:$SS[HL];
[h2][ph2]spectrumsynth=sample_rate=25600:$SS[HR];
[AL][AR]amerge,aresample=48000,highpass=f=40,
 volume='if(lt(t,2*$PH),0.22,if(lt(t,6*$PH),0.3,if(lt(t,14*$PH),0.8,if(lt(t,16*$PH),0.6,0.8))))*(1-between(t,6*$PH-0.48,6*$PH-0.001))':eval=frame[A0];
[A0][key]sidechaincompress=threshold=0.1:ratio=3:attack=5:release=160:makeup=1[A];
[HL][HR]amerge,aresample=48000,highpass=f=4500,highpass=f=4500,
 volume='0.55*(between(t,6*$PH,14*$PH)+between(t,16*$PH,22*$PH))':eval=frame[H];
[R]pan=stereo|c0=c0|c1=c0,volume=1.6[RS];
[A][RS][H]amix=inputs=3:normalize=0,acompressor=threshold=0.5:ratio=2:attack=20:release=250,volume=1.5,
 alimiter=limit=0.85,volume=0.92,afade=t=in:d=2,afade=t=out:st=174.32:d=10" -t $D "$@"
