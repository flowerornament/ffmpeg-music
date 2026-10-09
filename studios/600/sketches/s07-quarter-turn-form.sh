# Draft of the manifesto piece. Geometry G128: sr 12800, fft 1024, hop 256 -> 20 ms/col, 12.5 Hz/row.
# 6 cols = 16th at 125 bpm, 6 rows = 75 Hz. Phrase (frame) = 384 cols = 4 bars = 7.68 s.
# Chords are 4:5:6 triads on harmonic m of 75 Hz (m from the progression digits), with octaves.
# Turning by 90 deg sends partial p to 16th-step 64-p: every chord is also a rhythm.
PROG=15731573          # chord roots per 2 phrases: D F# C A ... (harmonics 1,5,7,3)
TRI=$(( (1<<4)|(1<<5)|(1<<6)|(1<<8)|(1<<10)|(1<<12)|(1<<16)|(1<<20)|(1<<24)|(1<<32)|(1<<40)|(1<<48) ))
TH="PI/2*if(lt(N,2),0,if(lt(N,6),(N-2)/4,if(lt(N,14),1,if(lt(N,16),0.5,if(lt(N,22),1,max(0,1-(N-21)/2))))))"
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=184.32,format=gray16,geq=lum='st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 st(3,mod(floor($PROG/pow(10,mod(floor(N/2),8))),10));st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.5)*exp(-pow((X-6+0.7*ld(2))/1.5,2))+eq(ld(2),0)*0.4*exp(-X/12))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),4)*between(X,20,200)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.5)*7000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(X,220)*pow((X-220)/163,2)*9000
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2500
+eq(ld(2),0)*between(ld(1),1,2)*4000',split[s1][s2];
[s2]geq=lum='st(5,$TH);st(6,(X-192)*cos(ld(5))+(320-Y)*sin(ld(5))+192);st(7,-(X-192)*sin(ld(5))+(320-Y)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(ld(6),512-ld(7))',split[r1][r2];
[s1]split[a1][a2];
nullsrc=s=384x513:r=12800/98304:d=184.32,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4,1)',split=3[pa][pr][pr2];
nullsrc=s=384x513:r=12800/98304:d=184.32,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4+mod(sin((512-Y)*91.7)*4375.85,1),1)',split[pw][pw2];
[a1][pa]spectrumsynth=sample_rate=12800:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[AL];
[a2][pw]spectrumsynth=sample_rate=12800:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[AR];
[r1][pr]spectrumsynth=sample_rate=12800:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[RL];
[r2][pw2]spectrumsynth=sample_rate=12800:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[RR];
[pr2]nullsink;
[AL][AR]amerge,aresample=48000,highpass=f=30,volume=0.6[A];
[RL][RR]amerge,aresample=48000,volume=1.2[R];
[A][R]amix=inputs=2:normalize=0,acompressor=threshold=0.25:ratio=3:attack=8:release=150,alimiter=limit=0.9" -t 184 "$@"
