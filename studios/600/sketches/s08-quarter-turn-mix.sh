# s07 + mixing: A heard through a horizontal blur (drum shadows become swells), stereo by phase
# decorrelation above 300 Hz, sidechained under R; an "air" layer = the rotated picture read at
# double sample rate (twice as fast, an octave up), high-passed, wide.
PH=7.68
PROG=15731573
TRI=$(( (1<<4)|(1<<5)|(1<<6)|(1<<8)|(1<<10)|(1<<12)|(1<<16)|(1<<20)|(1<<24)|(1<<32)|(1<<40)|(1<<48) ))
TH="PI/2*if(lt(M,2),0,if(lt(M,6),(M-2)/4,if(lt(M,14),1,if(lt(M,16),0.5,if(lt(M,22),1,max(0,1-(M-21)/2))))))"
SCORE="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 st(3,mod(floor($PROG/pow(10,mod(floor(M/2),8))),10));st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.5)*exp(-pow((X-6+0.7*ld(2))/1.5,2))+eq(ld(2),0)*0.4*exp(-X/12))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),4)*between(X,20,200)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.5)*7000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(X,220)*pow((X-220)/163,2)*9000
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2500
+eq(ld(2),0)*between(ld(1),1,2)*4000"
ROT="st(5,$TH);st(6,(X-192)*cos(ld(5))+(320-Y)*sin(ld(5))+192);st(7,-(X-192)*sin(ld(5))+(320-Y)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(ld(6),512-ld(7))"
PU="65535*mod((512-Y)*(X+2)/4,1)"
PW="65535*mod((512-Y)*(X+2)/4+gt(512-Y,24)*0.15*mod(sin((512-Y)*91.7)*4375.85,1),1)"
PW2="65535*mod((512-Y)*(X+2)/4+gt(512-Y,24)*0.25*mod(sin((512-Y)*17.3)*2375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
D=176
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$(echo "$SCORE" | sed 's/M/N/g')',split[s1][s2];
[s1]gblur=sigma=10:sigmaV=0.01,split[a1][a2];
[s2]geq=lum='$(echo "$ROT" | sed 's/M/N/g')'[r];
nullsrc=s=384x513:r=25600/98304:d=$D,format=gray16,geq=lum='$(echo "$SCORE" | sed 's/M/floor(N\/2)/g')',geq=lum='$(echo "$ROT" | sed 's/M/floor(N\/2)/g')',split[h1][h2];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU',split[pa][pr];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PW'[pw];
nullsrc=s=384x513:r=25600/98304:d=$D,format=gray16,geq=lum='$PW',split[ph1][ph1b];
nullsrc=s=384x513:r=25600/98304:d=$D,format=gray16,geq=lum='$PW2'[ph2];
[ph1b]nullsink;
[a1][pa]spectrumsynth=sample_rate=12800:$SS[AL];
[a2][pw]spectrumsynth=sample_rate=12800:$SS[AR];
[r][pr]spectrumsynth=sample_rate=12800:$SS,aresample=48000,volume='if(lt(t,2*$PH),0,1)':eval=frame,asplit[R][key];
[h1][ph1]spectrumsynth=sample_rate=25600:$SS[HL];
[h2][ph2]spectrumsynth=sample_rate=25600:$SS[HR];
[AL][AR]amerge,aresample=48000,highpass=f=40,volume=0.9[A0];
[A0][key]sidechaincompress=threshold=0.05:ratio=6:attack=5:release=180:makeup=1[A];
[HL][HR]amerge,aresample=48000,highpass=f=5000,highpass=f=5000,volume='if(lt(t,6*$PH),0,0.9)':eval=frame[H];
[R]pan=stereo|c0=c0|c1=c0,volume=1.4[RS];
[A][RS][H]amix=inputs=3:normalize=0,acompressor=threshold=0.3:ratio=2.5:attack=10:release=200,alimiter=limit=0.89,afade=t=out:st=$((D-8)):d=8" -t $D "$@"
