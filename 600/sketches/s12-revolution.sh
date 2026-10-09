# REVOLUTION draft: two readings of one picture, always perpendicular (theta and theta-90),
# turning once around over 30 phrases. 0: harmony + offbeat bass groove (270). 90: house + harmony.
# 180: negative harmony (partial p -> 64-p, phrase reversed) + house. 270: offbeat groove + negative harmony.
PH=7.68
PROG=159375139513751
TRI=$(( (1<<4)|(1<<5)|(1<<6)|(1<<8)|(1<<10)|(1<<12)|(1<<16)|(1<<20)|(1<<24)|(1<<32)|(1<<40)|(1<<48) ))
Q="if(lt(M,6),0,if(lt(M,8),(M-5)/3,if(lt(M,14),1,if(lt(M,16),1+(M-13)/3,if(lt(M,20),2,if(lt(M,22),2+(M-19)/3,if(lt(M,28),3,3+(M-27)/2)))))))"
SCORE="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));st(10,floor(ld(0)/6));st(11,ld(0)-6*ld(10));
 st(3,mod(floor($PROG/pow(10,floor(M/2))),10));st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000
+eq(mod(ld(10),4),2)*between(ld(10),2,62)*(exp(-ld(11)/2.2)*exp(-pow((X-377-0.8*ld(11))/1.3,2))+eq(ld(11),0)*0.5*exp(-(383-X)/10))*32000
+eq(mod(ld(1),8),4)*lte(ld(2),1)*between(X,100,284)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2))*sin(PI*(X-100)/184)*9000
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2500
+eq(ld(2),0)*between(ld(1),1,2)*4000"
# reading at angle (quarter-turns) QQ, fft 512: out col u -> t'=u/2, bin v -> f'=2v
RD="st(5,PI/2*(QQ));st(8,X/2-192);st(9,2*(512-Y)-192);
 st(6,ld(8)*cos(ld(5))+ld(9)*sin(ld(5))+192);st(7,-ld(8)*sin(ld(5))+ld(9)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(2*ld(6),512-ld(7))"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,40)*0.12*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
QT="if(lt(T,6),0,if(lt(T,8),(T-5)/3,if(lt(T,14),1,if(lt(T,16),1+(T-13)/3,if(lt(T,20),2,if(lt(T,22),2+(T-19)/3,if(lt(T,28),3,3+(T-27)/2)))))))"
QN=$(echo "$QT" | sed "s/T/floor(t\/$PH)/g")
D=230.4
R1=$(echo "$RD" | sed "s|QQ|$Q|; s/M/N/g")
R2=$(echo "$RD" | sed "s|QQ|$Q-1|; s/M/N/g")
RA=$(echo "$RD" | sed "s|QQ|$Q-1+mod(floor($Q+0.5),2)|; s/M/floor(N\/2)/g")
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$(echo "$SCORE" | sed 's/M/N/g')',scale=768x513:flags=bilinear,split[s1][s2];
[s1]geq=lum='$R1',crop=768:257:0:256,split[a1][a2];
[s2]geq=lum='$R2',crop=768:257:0:256,split[b1][b2];
nullsrc=s=384x513:r=25600/98304:d=$D,format=gray16,geq=lum='$(echo "$SCORE" | sed 's/M/floor(N\/2)/g')',scale=768x513:flags=bilinear,geq=lum='$RA',crop=768:257:0:256,split[h1][h2];
nullsrc=s=768x257:r=25600/98304:d=$D,format=gray16,geq=lum='$PW',split[hw1][hw2];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PU',split[p1][p2];
nullsrc=s=768x257:r=12800/98304:d=$D,format=gray16,geq=lum='$PW',split[w1][w2];
[a1][p1]spectrumsynth=sample_rate=12800:$SS[aL];[a2][w1]spectrumsynth=sample_rate=12800:$SS[aR];
[b1][p2]spectrumsynth=sample_rate=12800:$SS[bL];[b2][w2]spectrumsynth=sample_rate=12800:$SS[bR];
[h1][hw1]spectrumsynth=sample_rate=25600:$SS[hL];[h2][hw2]spectrumsynth=sample_rate=25600:$SS[hR];
[hL][hR]amerge,aresample=48000,highpass=f=4500,highpass=f=4500,volume='0.5*gte(t,2*$PH)*eq($QN,floor($QN))':eval=frame[H];
[aL][aR]amerge,aresample=48000,volume='0.3+1.0*pow(sin(PI/2*($QN)),2)':eval=frame[A];
[bL][bR]amerge,aresample=48000,volume='(0.3+1.0*pow(cos(PI/2*($QN)),2))*gte(t,2*$PH)':eval=frame[B];
[A][B][H]amix=inputs=3:normalize=0,highpass=f=28,acompressor=threshold=0.5:ratio=2:attack=20:release=250,volume=1.4,
 alimiter=limit=0.85,volume=0.92,afade=t=in:d=1,afade=t=out:st=222:d=8" -t $D "$@"
