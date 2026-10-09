#!/bin/sh
# 605 — PROLATION
# Studio 600 (Claude). Genre: Quarter-Turn. A chorale on the harmonic series of 75 Hz, no drums.
#
# One picture per phrase: a four-voice chorale painted as rows (a voice on harmonic p of 75 Hz is
# row 6p), each row with a breath-shaped envelope across the 7.68 s picture, over a drone on
# harmonic 1. The SAME sequence of pictures is read by spectrumsynth at three sample rates at once,
# which makes a prolation (mensuration) canon:
#     6400 Hz   half speed, an octave down  (augmentation; its fundamental becomes 37.5 Hz)
#    12800 Hz   as written
#    25600 Hz   double speed, an octave up  (diminution; wide)
# Ockeghem and Nancarrow built proportional canons by hand. Here the picture cannot be read at
# another speed without also being read in another octave. Every voice stays inside one harmonic
# series, so the canon is always in tune with itself. The augmentation's odd partials are new
# harmonics of 37.5 Hz: the slow voice grows a sub-octave harmony.
# The written voice is heard as two mirror readings: the picture turned by +theta (left) and
# -theta (right) about partial 10 at mid-phrase. When theta is not zero, every chord swoops into
# tune and out again across the phrase, rising in one ear and falling in the other; the two ears
# agree only at the phrase centre. At the end the picture turns a full quarter, and the chorale
# becomes its own rhythm.
# Form: written voice alone | + augmentation, 4-degree bends | + diminution | 11-degree bends
# (climax) | calm, two voices | the quarter-turn.
# Chorale (bass tenor alto soprano, harmonics of 75 Hz = D), 16 phrases:
#   4 8 10 12 | 4 9 12 14 | 5 10 15 20 | 6 12 15 18 | 7 14 18 21 | 4 11 14 16 | 3 12 15 18 | 4 8 10 16
#   5 10 13 20 | 6 9 12 15 | 7 10 14 21 | 9 12 18 27 | 4 10 15 20 | 6 11 15 22 | 4 9 14 18 | 2 8 10 16
# (stored below as two decimal digits per phrase, six phrases per number, phrase 0 rightmost)
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
F="(T+X/50)/$PH"
TH="PI/180*if(between($F,4,8),4*sin(PI*($F-4)/4),if(between($F,12,16),11*sin(PI*($F-12)/4),if(gte($F,20),90*min(1,($F-20)/3),0)))"
TURN="st(8,X-192);st(9,(512-Y)-60);
 st(6,ld(8)*cos(ld(5))+ld(9)*sin(ld(5))+192);st(7,-ld(8)*sin(ld(5))+ld(9)*cos(ld(5))+60);
 between(ld(6),0,383)*between(ld(7),0,512)*p(ld(6),512-ld(7))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,30)*0.18*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
D=184.32
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='st(9,floor(T/$PH+0.01));$SCORE',split[w1][w2];
[w1]geq=lum='st(5,$TH);$TURN'[wl];[w2]geq=lum='st(5,-($TH));$TURN'[wr];
nullsrc=s=384x513:r=25600/98304:d=$D,format=gray16,geq=lum='st(9,floor(2*T/$PH+0.01));$SCORE',split[u1][u2];
nullsrc=s=384x513:r=6400/98304:d=$D,format=gray16,geq=lum='st(9,floor(T/2/$PH+0.01));$SCORE'[d1];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU'[p1];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PW'[p2];
nullsrc=s=384x513:r=25600/98304:d=$D,format=gray16,geq=lum='$PU'[p3];
nullsrc=s=384x513:r=25600/98304:d=$D,format=gray16,geq=lum='$PW'[p4];
nullsrc=s=384x513:r=6400/98304:d=$D,format=gray16,geq=lum='$PU'[p5];
[wl][p1]spectrumsynth=sample_rate=12800:$SS[WL];[wr][p2]spectrumsynth=sample_rate=12800:$SS[WR];
[u1][p3]spectrumsynth=sample_rate=25600:$SS[UL];[u2][p4]spectrumsynth=sample_rate=25600:$SS[UR];
[d1][p5]spectrumsynth=sample_rate=6400:$SS,aresample=48000,pan=stereo|c0=c0|c1=c0,volume='0.85*clip((t/$PH-3.5)/1.5,0,1)*(1-0.3*between(t/$PH,16,20))*clip((22.5-t/$PH)/2.5,0,1)':eval=frame[DD];
[WL][WR]amerge,aresample=48000,volume='(0.55+0.45*clip(t/$PH/12,0,1)-0.25*between(t/$PH,16,20))*(1+1.5*clip((t/$PH-21)/2,0,1))':eval=frame[WW];
[UL][UR]amerge,aresample=48000,highpass=f=300,volume='0.5*clip((t/$PH-7.5)/1.5,0,1)*(1-between(t/$PH,16,20))*clip((22.5-t/$PH)/2.5,0,1)':eval=frame[UU];
[DD][WW][UU]amix=inputs=3:normalize=0,highpass=f=22,
 acompressor=threshold=0.4:ratio=2:attack=40:release=400,volume=1.3,alimiter=limit=0.85,volume=0.92,
 afade=t=in:d=3,afade=t=out:st=172:d=12" -t $D "$@"
