#!/bin/sh
# 606 — SYMPLECTIC
# Studio 600 (Claude). Genre: Quarter-Turn. 125 bpm, harmonic series of 75 Hz, 24 phrases.
#
# The linear maps of the time-frequency plane that preserve area (the Gabor uncertainty cell)
# form one group, SL(2,R). Its three kinds of motion are rotation, shear and squeeze. Quarter-Turn
# pieces use the rotations. This one stays turned 90 degrees (the picture is a groove) and uses the
# other two:
#   SHEAR    time offset proportional to frequency (t -> t + b f). Small b is swing that depends on
#            pitch: hats and snares lean late or early against the kick (Mark Fell's micro-timing
#            given by timbre). Large b is dispersion: every hit becomes a chirp, a laser.
#   SQUEEZE  t -> s t, f -> f / s. This is varispeed. s = 2 is the half-time drop: the same groove
#            at half speed and an octave down, so the kick falls to 30-40 Hz. Gliding s from 1 to 2
#            inside one picture is a tape stop. s = 1/2 is double time, an octave up.
# Underneath, the unturned picture is the harmony (heard blurred and ducked). Chords are 4:5:6 on
# harmonic m (m per two phrases: 1 5 7 3 ...), and once turned they are the rim pattern.
# Form (phrases): harmony 0-1 | straight 2-5 | swing breathing 6-9 | lasers 10-11 | tape stop 12 |
#                 half-time 13-16 | double time 17 | straight + swing 18-21 | harmony out 22-23
PH=7.68
M="floor(T/$PH+0.01)"
PROG=37513751375137
TRI=282578801202544
SCORE="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 st(3,mod(floor($PROG/pow(10,floor($M/2))),10));st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),3)*between(X,40,220)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.4)*8000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(X,250)*pow((X-250)/133,2)*12000
+eq(mod(ld(1),2),1)*between(ld(1),33,63)*eq(ld(2),0)*gte(X,300)*pow((X-300)/83,3)*5000*gte($M,18)
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2200
+eq(ld(2),0)*between(ld(1),1,2)*3500"
# per output pixel: phrase position F (10 ms columns); shear b(F); squeeze s(F)
F="(T+X/100)/$PH"
B="if(between($F,6,10),0.012*sin(2*PI*($F-6)/2),if(between($F,10,12),0.07*if(mod(floor(($F-10)*4),2),1,-1),if(between($F,18,22),0.008,0)))"
SQ="if(between($F,12,13),1+($F-12),if(between($F,13,17),2,if(between($F,17,18),0.5,1)))"
# output (u = X/2 score columns, v = 2(512-Y) score rows) -> shear -> squeeze -> turned 90: col = v, row = 384 - u
MAP="st(8,X/2);st(9,2*(512-Y));st(8,ld(8)-($B)*ld(9));st(5,$SQ);st(8,ld(8)/ld(5));st(9,ld(9)*ld(5));
 between(ld(9),0,383)*between(384-ld(8),0,383)*p(2*ld(9),128+ld(8))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,24)*0.15*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
SIL="(1-between(t,2*$PH-0.48,2*$PH-0.001)-between(t,13*$PH-0.24,13*$PH-0.001))"
D=184.32
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$SCORE',split[s1][s2];
[s1]gblur=sigma=10:sigmaV=0.01,split[a1][a2];
[s2]scale=768x513:flags=bilinear,geq=lum='$MAP',crop=768:257:0:256,split[r][hh];
[hh]fps=25600/98304,split[h1][h2];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[pa];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PW'[pw];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[pr];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PU'[ph1];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PW'[ph2];
[a1][pa]spectrumsynth=sample_rate=12800:$SS[AL];[a2][pw]spectrumsynth=sample_rate=12800:$SS[AR];
[r][pr]spectrumsynth=sample_rate=12800:$SS,aresample=48000,
 volume='if(lt(t,2*$PH),0,if(lt(t,22*$PH),1+0.45*between(t,13*$PH,17*$PH),0))*$SIL':eval=frame,asplit[R][key];
[h1][ph1]spectrumsynth=sample_rate=25600:$SS[HL];[h2][ph2]spectrumsynth=sample_rate=25600:$SS[HR];
[AL][AR]amerge,aresample=48000,highpass=f=40,
 volume='if(lt(t,2*$PH),0.4,if(between(t,13*$PH,17*$PH),0.25,0.5))*$SIL':eval=frame[A0];
[A0][key]sidechaincompress=threshold=0.1:ratio=3:attack=5:release=160[A];
[HL][HR]amerge,aresample=48000,highpass=f=4500,highpass=f=4500,
 volume='0.55*(between(t,6*$PH,12*$PH)+between(t,17*$PH,22*$PH))':eval=frame[H];
[R]pan=stereo|c0=c0|c1=c0,volume=1.5[RS];
[A][RS][H]amix=inputs=3:normalize=0,highpass=f=20,acompressor=threshold=0.5:ratio=2:attack=20:release=250,volume=1.4,
 alimiter=limit=0.85,volume=0.92,afade=t=in:d=1,afade=t=out:st=174.32:d=10" -t $D "$@"
