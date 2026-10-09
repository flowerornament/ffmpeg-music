# Column synthesis: spectrumsynth fed 1-pixel-wide frames at 50 fps (one STFT column per frame),
# each column computed by geq. The score is the 601 picture repeated as a torus (period 384 in
# time and in frequency); the reading walks across it in direction theta. Walk position is the
# closed-form integral of the direction:  0..2 phrases theta=0, then theta turns linearly to 90 deg
# over 2 phrases (omega = PI/2/768 per column), then holds 90.
# position (columns): theta=0 phase: (n, 0). turning: x = 768 + (sin(th))/w, y = (1-cos(th))/w.
# hold 90: x = 768 + 1/w, y = 1/w + (n-1536).
TRI=282578801202544
SCORE="st(0,mod(ld(7)+1e6*384,384));st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 st(3,1);st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.5)*exp(-pow((ld(6)-6+0.7*ld(2))/1.5,2))+eq(ld(2),0)*0.6*exp(-ld(6)/12))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),4)*between(ld(6),20,200)*mod(sin(floor(ld(6))*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.5)*7000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(ld(6),220)*pow((ld(6)-220)/163,2)*9000
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-ld(6)/120))*2500
+eq(ld(2),0)*between(ld(1),1,2)*4000"
W="(PI/2/768)"
WALK="st(5,-if(lt(N,768),0,if(lt(N,1536),(N-768)*$W,PI/2)));
 st(8,if(lt(N,768),N,if(lt(N,1536),768+sin(-ld(5))/$W,768+1/$W)));
 st(9,if(lt(N,768),0,if(lt(N,1536),(cos(ld(5))-1)/$W,-1/$W-(N-1536))));
 st(6,mod(ld(8)-(512-Y-192)*sin(ld(5))+1e6*384,384));st(7,ld(9)+(512-Y-192)*cos(ld(5))+192);"
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=1x513:r=50,format=gray16,geq=lum='$WALK $SCORE'[m];
nullsrc=s=1x513:r=50,format=gray16,geq=lum='65535*mod((512-Y)*(N+2)/4,1)'[p];
[m][p]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1,aresample=48000" -t 46 "$@"
