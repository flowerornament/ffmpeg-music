#!/bin/sh
# 608 — half-turn
# Studio 600 (Claude). Genre: Quarter-Turn. An interlude: the chorale of 605 turned 180 degrees.
#
# A half-turn about (192,192) plays every 7.68 s picture backwards and sends harmonic p of 75 Hz
# to harmonic 64-p: negative harmony that stays inside the overtone series. The chorale's 4:5:6
# chords become clusters near the top (60:59:58), its breaths become inhalations. Heard at 12800
# Hz (written) and at 6400 Hz (half speed, an octave down, where the clusters land among 1-2 kHz).
# Five pictures of the chorale, each at half speed for the low reading.
PH=7.68
SCORE="st(9,mod(ld(9),16));st(0,512-Y);
 st(1,mod(floor(if(lt(ld(9),6),40706050404,if(lt(ld(9),12),90706050403,2040604))/pow(100,mod(ld(9),6))),100));
 st(2,mod(floor(if(lt(ld(9),6),111412100908,if(lt(ld(9),12),121009100812,8091110))/pow(100,mod(ld(9),6))),100));
 st(3,mod(floor(if(lt(ld(9),6),141815151210,if(lt(ld(9),12),181412131015,10141515))/pow(100,mod(ld(9),6))),100));
 st(4,mod(floor(if(lt(ld(9),6),162118201412,if(lt(ld(9),12),272115201618,16182220))/pow(100,mod(ld(9),6))),100));
 st(5,clip(X/40,0,1)*clip((383-X)/70,0,1));
 st(6,clip(X/90,0,1)*clip((383-X)/40,0,1)*(0.8+0.2*sin(PI*X/383)));
 ld(5)*(eq(ld(0),6*ld(1))*1.0+eq(ld(0),12*ld(1))*0.25+eq(ld(0),6*ld(2))*0.7+eq(ld(0),6*ld(3))*0.7)*6000
 +ld(6)*(eq(ld(0),6*ld(4))*1.0+eq(ld(0),12*ld(4))*0.15+eq(ld(0),6*ld(4)+1)*0.12)*6500
 +eq(ld(0),6)*(0.7+0.3*cos(2*PI*X/384))*5500"
HALF="st(9,640-Y);gte(Y,128)*p(383-X,ld(9))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,30)*0.2*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
D=38.4
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='st(9,floor(T/$PH+0.01)+8);$SCORE',geq=lum='$HALF',split[w1][w2];
nullsrc=s=384x513:r=6400/98304:d=$D,format=gray16,geq=lum='st(9,floor(T/2/$PH+0.01)+8);$SCORE',geq=lum='$HALF'[d1];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[p1];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PW'[p2];
nullsrc=s=384x513:r=6400/98304:d=$D,format=gray16,geq=lum='$PU'[p3];
[w1][p1]spectrumsynth=sample_rate=12800:$SS[WL];[w2][p2]spectrumsynth=sample_rate=12800:$SS[WR];
[d1][p3]spectrumsynth=sample_rate=6400:$SS,aresample=48000,pan=stereo|c0=c0|c1=c0[DD];
[WL][WR]amerge,aresample=48000,volume=0.5[WW];
[DD][WW]amix=inputs=2:normalize=0,highpass=f=30,aecho=in_gain=0.8:out_gain=0.8:delays=720|1080:decays=0.3|0.25,
 acompressor=threshold=0.4:ratio=2:attack=40:release=400,volume=1.35,alimiter=limit=0.85,volume=0.92,
 afade=t=in:d=2,afade=t=out:st=30:d=8" -t $D "$@"
