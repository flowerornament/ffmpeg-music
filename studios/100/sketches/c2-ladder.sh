# c2 ladder: sr 30037, N 65536 -> F = 0.45834 Hz = one bar (110 bpm); root A1 = row 120.
# the ladder: a comb of rows with spacing d = d pulses per bar. d climbs 1..16 (every tuplet),
# then glides to 120 (=55 Hz, the tonic), plays the bass line i VI III VII as spacings, falls back.
W=336
SR=30037
F=0.458328
K="(32767-mod(Y,32768))"
ADV="$K*X/4"
B="floor(X/4)"
P="mod(floor($B/2),4)"
ROOT="(120-24*eq($P,1)+24*eq($P,2)-12*eq($P,3))"
D="if(lt($B,16),1+$B,if(lt($B,32),round(16*pow(7.5,(X-64)/64)),if(lt($B,64),$ROOT,if(lt($B,76),max(1,round(120*pow(1/60,(X-256)/48))),1))))"
FC="(1200*pow(ld(1)*$F*2.5/1200,clip((ld(1)-8)/60,0,1)))"
LM="st(1,$D);eq(mod($K,ld(1)),0)*between($K*$F,max(ld(1)*$F,30),9000)*max(1,255+2.125*(-56+20*log(min(ld(1),12))/log(10)+18*clip((ld(1)-12)/30,0,1)-9*pow(log($K*$F/$FC)/log(2),2)-60*gte($B,82)))"
SS="spectrumsynth=sample_rate=$SR:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75,aresample=48000"
img(){ echo "color=c=black:s=${W}x$2:d=1:r=1,format=gray,geq=lum='$1'"; }
# pad: chord rows folded into [450,900), +1 row in the right ear for odd chord tones
T3="if(eq($P,0),1.2,1.25)"
PT="st(3,ld(2)*pow(2,-floor(log(ld(2)/450)/log(2))));(eq($K,round(ld(3))+gt(Y,32767)*ld(4))+0.5*eq($K,round(2*ld(3)))+0.3*eq($K,round(3*ld(3))))"
PM="st(4,0);st(2,$ROOT*4);st(5,$PT);st(4,1);st(2,$ROOT*4*$T3);st(5,ld(5)+$PT);st(4,0);st(2,$ROOT*6);st(5,ld(5)+$PT);st(4,1);st(2,$ROOT*8);st(5,ld(5)+$PT);gt(ld(5),0)*(255+2.125*(-20+20*log(ld(5))/log(10)))*between($B,20,75)"
ffmpeg -hide_banner -y -filter_complex "
$(img "$LM" 65536)[lm];$(img "255*mod($ADV,1)" 65536)[lp];[lm][lp]$SS,volume=0.5,astats=measure_perchannel=0:measure_overall=RMS_level+Peak_level[lad];
$(img "$PM" 65536)[pm];$(img "255*mod($ADV+mod(sin($K*12.9898)*43758.5453,1),1)" 65536)[pp];[pm][pp]$SS,astats=measure_perchannel=0:measure_overall=RMS_level+Peak_level[pad];
$(img "eq(mod($K,4),0)*between($B,8,63)*max(0,255+2.125*(-26-8.7*pow(($K*$F-55)/30,2)))" 32768)[km];$(img "255*mod($ADV-2.2*log($K*$F+1),1)" 32768)[kp];[km][kp]${SS/channels=2/channels=1},astats=measure_perchannel=0:measure_overall=RMS_level+Peak_level[kick];
[lad][pad][kick]amix=inputs=3:normalize=0,volume=2,alimiter=limit=0.9:level=0" "$@"
