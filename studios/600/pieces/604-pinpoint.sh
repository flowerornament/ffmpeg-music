#!/bin/sh
# 604 — PINPOINT
# Studio 600 (Claude). Genre: Quarter-Turn. 125 bpm, 75 Hz harmonic series, 22 phrases.
#
# A sentence in Braille, drawn by drawtext with the system font "Apple Braille Pinpoint 6 Dot",
# is the drum machine. That font draws absent dots as faint pinpoints, so every cell carries
# ghost notes. One braille cell = one beat (left dot column on the beat, right column on the
# "and"); one line of 16 cells = one 4-bar phrase. geq samples the rendered dots and paints them
# into the score S as strokes; turned 90 degrees they are hits:
#     top dot row (1,4)    -> kick      (stroke at the phrase start = low once turned)
#     middle row  (2,5)    -> snare     (noise mid-phrase = mid band)
#     bottom row  (3,6)    -> hat       (swell at the phrase end = high)
# The sentence:  "the beat is a chord turned on its side. read it with your body."
# Unturned, the same picture is a slow harmony: 4:5:6 triads on harmonics 1, 5, 7, 3 (one per
# text line) with the text's shadow passing through it; it is heard blurred and ducked.
# Form: harmony alone | the text, each line twice | breakdown turning (falling glissandi) | the
# text again with air | coda.
PH=7.68
M="floor(T/$PH+0.01)"
TXT="⠞⠓⠑⠀⠃⠑⠁⠞⠀⠊⠎⠀⠁⠀⠉⠓
⠕⠗⠙⠀⠞⠥⠗⠝⠑⠙⠀⠕⠝⠀⠊⠞
⠎⠀⠎⠊⠙⠑⠲⠀⠗⠑⠁⠙⠀⠊⠞⠀
⠺⠊⠞⠓⠀⠽⠕⠥⠗⠀⠃⠕⠙⠽⠲⠀"
LINE="mod(floor(max($M-2,0)/2)-4*gte($M,12),4)"
ROOT="mod(floor(3751/pow(10,$LINE)),10)"
TRI=282578801202544
# dot strength at (ld5, ld6): 5-point sum over the rendered font; raised dots ~3.5, pinpoints ~0.7
DOT="(p(ld(5)-1,ld(6))+p(ld(5),ld(6))+p(ld(5)+1,ld(6))+p(ld(5),ld(6)-1)+p(ld(5),ld(6)+1))/65535"
VEL="if(gt(ld(9),2),1,0.05*gt(ld(9),0.3))"
SC="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));st(3,64-ld(1));
 lte(ld(0),383)*gte(ld(1),1)*(
 not(mod(ld(3),2))*(st(5,5+16.4*floor(ld(3)/4)+3*mod(ld(3),4));st(6,1+27*$LINE);
  st(9,$DOT)*0+$VEL*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000
 +st(6,ld(6)+6)*0+st(9,$DOT)*0+$VEL*lte(ld(2),3)*between(X,50,220)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.3)*8000
 +st(6,ld(6)+6)*0+st(9,$DOT)*0+$VEL*lte(ld(2),1)*gte(X,280)*pow((X-280)/103,2)*15000)
 +eq(ld(2),0)*st(4,ld(1)/$ROOT)*0+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2200
 +eq(ld(2),0)*between(ld(1),1,2)*3500)"
F="(T+X/100)/$PH"
TH="PI/2*if(between($F,10,12),0.3+0.35*($F-10),1)"
ROT="st(5,$TH);st(8,X/2-192);st(9,2*(512-Y)-192);
 st(6,ld(8)*cos(ld(5))+ld(9)*sin(ld(5))+192);st(7,-ld(8)*sin(ld(5))+ld(9)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(2*ld(6),512-ld(7))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,24)*0.15*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
SIL="(1-between(t,2*$PH-0.48,2*$PH-0.001)-between(t,12*$PH-0.48,12*$PH-0.001))"
D=168.96
ffmpeg -hide_banner -y -filter_complex "
color=black:s=384x513:r=12800/98304:d=$D,format=gray,
 drawtext=fontfile='/System/Library/Fonts/Apple Braille Pinpoint 6 Dot.ttf':text='$TXT':fontsize=24:fontcolor=white:x=0:y=0,
 format=gray16,geq=lum='$SC',split[s1][s2];
[s1]gblur=sigma=10:sigmaV=0.01,split[a1][a2];
[s2]scale=768x513:flags=bilinear,geq=lum='$ROT',crop=768:257:0:256,split[r][hh];
[hh]fps=25600/98304,split[h1][h2];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[pa];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PW'[pw];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[pr];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PU'[ph1];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PW'[ph2];
[a1][pa]spectrumsynth=sample_rate=12800:$SS[AL];[a2][pw]spectrumsynth=sample_rate=12800:$SS[AR];
[r][pr]spectrumsynth=sample_rate=12800:$SS,aresample=48000,
 volume='if(lt(t,2*$PH),0,if(lt(t,10*$PH),1,if(lt(t,12*$PH),0.25+0.1*(floor(t/$PH)-10),if(lt(t,20*$PH),1,0))))*$SIL':eval=frame,asplit[R][key];
[h1][ph1]spectrumsynth=sample_rate=25600:$SS[HL];[h2][ph2]spectrumsynth=sample_rate=25600:$SS[HR];
[AL][AR]amerge,aresample=48000,highpass=f=40,volume='if(lt(t,2*$PH),0.35,if(between(t,10*$PH,12*$PH),0.7,0.45))*$SIL':eval=frame[A0];
[A0][key]sidechaincompress=threshold=0.1:ratio=3:attack=5:release=160[A];
[HL][HR]amerge,aresample=48000,highpass=f=4500,highpass=f=4500,volume='0.6*between(t,12*$PH,20*$PH)':eval=frame[H];
[R]pan=stereo|c0=c0|c1=c0,volume=1.5[RS];
[A][RS][H]amix=inputs=3:normalize=0,acompressor=threshold=0.5:ratio=2:attack=20:release=250,volume=1.4,
 alimiter=limit=0.85,volume=0.92,afade=t=in:d=1,afade=t=out:st=159.96:d=9" -t $D "$@"
