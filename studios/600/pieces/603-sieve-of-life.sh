#!/bin/sh
# 603 — SIEVE OF LIFE
# Studio 600 (Claude). Genre: Quarter-Turn. 125 bpm, harmonic series of 75 Hz, 22 phrases.
#
# Two Conway Life universes (64x64, seeds 7 and 11; one generation per 4-bar phrase) are the
# texture. A Xenakis sieve on the partial index is the law: only rows whose partial q lies in the
# sieve may sound. A sieve on harmonics is a chord; turned 90 degrees, the same sieve on 16th-steps
# is a rhythm. Xenakis used sieves for both pitch and time. Here they are literally one object.
#   cell (col i, partial q) = 6x6 px = (16th i, harmonic q of 75 Hz), shaped as a soft bump
#   A (as drawn):  q sounds during 16th i     -> a harmonic-series melody written by Life
#   B (turned):    a hit at step 64-q whose spectrum is the 75-Hz bands i where that row lives
# Left ear = universe 7, right ear = universe 11 (melodies and drum spectra differ L/R, rhythm
# is shared because the sieve is shared). A "pedal" adds the only non-Life element: kick strokes on
# q%4==0 at the phrase start (low = early once turned).
# Air: the turned picture read at 25.6 kHz (twice as fast, an octave up), high-passed.
# Form: 2 phrases of melody, groove, a breakdown (8-9: Life alone, unturned), a continuous turn back up
# (10-11: 0 -> 90 degrees, bending glissandi), groove, coda.
# Sieves, 4 phrases each: (4,0)u(6,1)u(16,10) | (4,0)u(5,2)u(12,7) | (3,0)u(8,5)u(16,2) |
#                         (4,0)u(7,3)u(9,4)   | back to the first.
PH=7.68
M="floor(T/$PH+0.01)"   # phrase index inside geq (T = frame time)
SV="if(lt(floor($M/4),1)+gte(floor($M/4),5),eq(mod(ld(1),4),0)+eq(mod(ld(1),6),1)+eq(mod(ld(1),16),10),
 if(eq(floor($M/4),1),eq(mod(ld(1),4),0)+eq(mod(ld(1),5),2)+eq(mod(ld(1),12),7),
 if(eq(floor($M/4),2),eq(mod(ld(1),3),0)+eq(mod(ld(1),8),5)+eq(mod(ld(1),16),2),
 eq(mod(ld(1),4),0)+eq(mod(ld(1),7),3)+eq(mod(ld(1),9),4))))"
CELL="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));lte(ld(0),383)*gte(ld(1),1)*(
  min(1,$SV)*gt(p(X,Y),30000)*exp(-ld(2)/1.3)*sin(PI*(mod(X,6)+0.5)/6)*6000*(0.6+0.4*lt(ld(1),24))
 +eq(mod(ld(1),4),0)*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000*gte($M,2)*not(between($M,8,11)))"
F="(T+X/100)/$PH"
TH="PI/2*if(between($F,8,10),0,if(between($F,10,12),($F-10)/2,1))"
ROT="st(5,$TH);st(8,X/2-192);st(9,2*(512-Y)-192);
 st(6,ld(8)*cos(ld(5))+ld(9)*sin(ld(5))+192);st(7,-ld(8)*sin(ld(5))+ld(9)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(2*ld(6),512-ld(7))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
LIFE="r=12800/98304:ratio=0.2,trim=start_frame=200,setpts=PTS-STARTPTS,format=gray16,scale=384x384:flags=neighbor,pad=384:513:0:129"
D=168.96
ffmpeg -hide_banner -y -filter_complex "
life=s=64x64:seed=7:$LIFE,geq=lum='$CELL',split[l1][l2];
life=s=64x64:seed=11:$LIFE,geq=lum='$CELL',split[r1][r2];
[l2]scale=768x513:flags=bilinear,geq=lum='$ROT',crop=768:257:0:256,split[bl][hl0];
[r2]scale=768x513:flags=bilinear,geq=lum='$ROT',crop=768:257:0:256,split[br][hr0];
[hl0]fps=25600/98304[hl];[hr0]fps=25600/98304[hr];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PU',split[p5][p6];
[hl][p5]spectrumsynth=sample_rate=25600:$SS[HL];[hr][p6]spectrumsynth=sample_rate=25600:$SS[HR];
[HL][HR]amerge,aresample=48000,highpass=f=5000,highpass=f=5000,volume='between(t,2*$PH,8*$PH)+between(t,12*$PH,20*$PH)':eval=frame[H];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU',split[p1][p2];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PU',split[p3][p4];
[l1][p1]spectrumsynth=sample_rate=12800:$SS[AL];[r1][p2]spectrumsynth=sample_rate=12800:$SS[AR];
[bl][p3]spectrumsynth=sample_rate=12800:$SS[BL];[br][p4]spectrumsynth=sample_rate=12800:$SS[BR];
[AL][AR]amerge,aresample=48000,highpass=f=35,asplit[A][Aw];
[Aw]aecho=in_gain=0.6:out_gain=0.5:delays=360|600:decays=0.35|0.3,highpass=f=300[Ae];
[BL][BR]amerge,aresample=48000,volume='if(lt(t,2*$PH),0,if(lt(t,8*$PH),1,if(lt(t,10*$PH),0,if(lt(t,12*$PH),0.4+0.25*(floor(t/$PH)-10),if(lt(t,20*$PH),1.1,0)))))*(1-between(t,2*$PH-0.48,2*$PH-0.001)-between(t,12*$PH-0.48,12*$PH-0.001))':eval=frame,asplit[B][key];
[A][key]sidechaincompress=threshold=0.1:ratio=2.5:attack=5:release=160[Ad];
[Ad][Ae][B][H]amix=inputs=4:weights=0.9 0.35 1.3 1.6:normalize=0,acompressor=threshold=0.5:ratio=2:attack=20:release=250,volume=1.4,
 alimiter=limit=0.85,volume=0.92,afade=t=in:d=0.5,afade=t=out:st=159.96:d=9" -t $D "$@"
