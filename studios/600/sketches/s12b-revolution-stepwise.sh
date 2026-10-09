#!/bin/sh
# 602 — REVOLUTION
# Studio 600 (Claude). Genre: Quarter-Turn. 125 bpm on the harmonic series of 75 Hz, 30 phrases.
#
# One picture S of the time-frequency plane (384 x 513 gray16, redrawn every 4-bar phrase) is read
# by two spectrumsynths whose angles are always perpendicular: theta and theta-90. Over the piece
# theta makes one full revolution, dwelling at each quarter:
#     0   harmony                                  + the 270 groove: ticks on the beat, offbeat bass
#    90   house groove (kick low, hats high)       + harmony
#   180   negative harmony: partial p -> 64-p,     + house groove
#         every phrase played backwards
#   270   offbeat groove                           + negative harmony
#   360   home
# Between the quarters both readings tilt in opposite directions: a crosshatch of rising and
# falling glissandi, with the kicks becoming staircases of blips.
# Why it is in tune: in this geometry (12800 Hz, fft 1024, hop 256) six pixels are both a 16th note
# and 75 Hz, so partial p is step p (or 64-p), and a half-turn sends partial p to partial 64-p,
# which is still a harmonic of 75 Hz. Kick strokes sit at the phrase start (low at 90, high at 270),
# offbeat strokes at the phrase end (high at 90, a bass boom at 270). "Air" is the current groove
# reading at double sample rate: the same groove twice as fast and an octave up, high-passed.
# Readings use fft 512 (sharper kicks), the score is defined on the fft-1024 grid and resampled.
PH=7.68
PROG=159375139513751   # chord root harmonic per 2 phrases (read right to left): 1 5 7 3 1 5 9 3 1 5 7 3 9 5 1
TRI=282578801202544    # bit r set for r in {4,5,6,8,10,12,16,20,24,32,40,48}: 4:5:6 and its octaves
M="floor(T/$PH+0.01)"  # phrase index inside geq (T = frame time: valid at any frame rate)
m="floor(t/$PH+0.01)"  # the same for audio filters
# Q = angle in quarter-turns per phrase: dwell 0 | turn | dwell 1 | turn | dwell 2 | turn | dwell 3 | home
Q="if(lt($M,6),0,if(lt($M,8),($M-5)/3,if(lt($M,14),1,if(lt($M,16),1+($M-13)/3,if(lt($M,20),2,if(lt($M,22),2+($M-19)/3,if(lt($M,28),3,3+($M-27)/2)))))))"
q="if(lt($m,6),0,if(lt($m,8),($m-5)/3,if(lt($m,14),1,if(lt($m,16),1+($m-13)/3,if(lt($m,20),2,if(lt($m,22),2+($m-19)/3,if(lt($m,28),3,3+($m-27)/2)))))))"
# S(X, k=512-Y): q=ceil(k/6) partial, j=6q-k rows below it
#   kick strokes  q%4==0, early columns (90: low kick; 270: high tick)
#   offbeat strokes on block floor(k/6)%4==2, rows above, late columns (90: high tick; 270: bass boom)
#   snare flicker q%8==4 mid-phrase, chord rows 4:5:6 x root, bass partials 1 and 2
SCORE="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 st(3,mod(floor($PROG/pow(10,floor($M/2))),10));st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000
+eq(mod(floor(ld(0)/6),4),2)*between(floor(ld(0)/6),2,62)*(exp(-mod(ld(0),6)/2.2)*exp(-pow((X-377-0.8*mod(ld(0),6))/1.3,2))+eq(mod(ld(0),6),0)*0.5*exp(-(383-X)/10))*32000
+eq(mod(ld(1),8),4)*lte(ld(2),1)*between(X,100,284)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2))*sin(PI*(X-100)/184)*9000
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2500
+eq(ld(2),0)*between(ld(1),1,2)*4000"
# a reading turned by A quarter-turns about (192,192), resampled to fft 512: col u -> t'=u/2, bin v -> f'=2v
TURN="st(8,X/2-192);st(9,2*(512-Y)-192);
 st(6,ld(8)*cos(ld(5))+ld(9)*sin(ld(5))+192);st(7,-ld(8)*sin(ld(5))+ld(9)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(2*ld(6),512-ld(7))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,40)*0.12*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
SIL="(1-between(t,8*$PH-0.48,8*$PH-0.001)-between(t,22*$PH-0.48,22*$PH-0.001))"
D=230.4
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$SCORE',scale=768x513:flags=bilinear,split=3[s1][s2][s3];
[s1]geq=lum='st(5,PI/2*($Q));$TURN',crop=768:257:0:256,split[a1][a2];
[s2]geq=lum='st(5,PI/2*($Q-1));$TURN',crop=768:257:0:256,split[b1][b2];
[s3]fps=25600/98304,geq=lum='st(5,PI/2*($Q-1+mod(floor($Q+0.5),2)));$TURN',crop=768:257:0:256,split[h1][h2];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PW',split[hw1][hw2];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PU',split[p1][p2];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PW',split[w1][w2];
[a1][p1]spectrumsynth=sample_rate=12800:$SS[aL];[a2][w1]spectrumsynth=sample_rate=12800:$SS[aR];
[b1][p2]spectrumsynth=sample_rate=12800:$SS[bL];[b2][w2]spectrumsynth=sample_rate=12800:$SS[bR];
[h1][hw1]spectrumsynth=sample_rate=25600:$SS[hL];[h2][hw2]spectrumsynth=sample_rate=25600:$SS[hR];
[hL][hR]amerge,aresample=48000,highpass=f=4500,highpass=f=4500,volume='0.5*gte(t,2*$PH)*eq($q,floor($q))':eval=frame[H];
[aL][aR]amerge,aresample=48000,volume='(0.45+0.85*pow(sin(PI/2*($q)),2))*$SIL':eval=frame[A];
[bL][bR]amerge,aresample=48000,volume='(0.45+0.85*pow(cos(PI/2*($q)),2))*gte(t,2*$PH)*$SIL':eval=frame[B];
[A][B][H]amix=inputs=3:normalize=0,highpass=f=28,acompressor=threshold=0.5:ratio=2:attack=20:release=250,volume=1.4,
 alimiter=limit=0.85,volume=0.92,afade=t=in:d=1,afade=t=out:st=222:d=8" -t $D "$@"
