#!/bin/sh
# 507 — Dead Air
# silenceremove is a broadcast repair tool: it deletes dead air. Here it deletes the end of
# every room's ring. Each knock lasts exactly as long as the room keeps it above -30 dB,
# then the next knock begins. So the RHYTHM is decided by the acoustics: a hard knock in a
# corner, where every mode is excited, rings long; a soft knock at the centre, where half
# the modes cancel, is gone almost at once. A rhythm written as DYNAMICS and PLACES.
# Two rooms, trimmed separately, so they never agree about time and drift through each
# other like two hand drummers:
#   low  : A room (55, 68.75, 82.5 Hz), knocked once per input second
#   high : E room (82.5, 103.1, 123.75 Hz — up a fifth), knocked every 0.6 input seconds
# Velocities and places are digit tables (velocity 1..9, place 0 corner 1 centre 2 wall),
# changing every 16 knocks; mallet hardness follows velocity, and loud knocks carry a
# 2-ms slap of noise that reaches the upper modes. Two ears per room.
room(){ # fx fy fz  sx sy sz  rx ry rz  damping
echo "st(4,0);st(0,1);while(lt(ld(0),25),st(3,ld(0)*$1);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$4)*cos(PI*ld(0)*$7)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,1);while(lt(ld(0),25),st(3,ld(0)*$2);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$5)*cos(PI*ld(0)*$8)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,1);while(lt(ld(0),25),st(3,ld(0)*$3);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$6)*cos(PI*ld(0)*$9)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,0);while(lt(ld(0),6),st(1,0);while(lt(ld(1),6),st(2,0);while(lt(ld(2),5),st(5,gt(ld(0),0)+gt(ld(1),0)+gt(ld(2),0));st(3,sqrt(pow(ld(0)*$1,2)+pow(ld(1)*$2,2)+pow(ld(2)*$3,2)));st(4,ld(4)+gte(ld(5),2)*pow(0.45,ld(5)-1)*cos(PI*ld(0)*$4)*cos(PI*ld(1)*$5)*cos(PI*ld(2)*$6)*cos(PI*ld(0)*$7)*cos(PI*ld(1)*$8)*cos(PI*ld(2)*$9)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));0.04*ld(4)"
}
EL="0.11 0.07 0.19"; ER="0.17 0.13 0.05"
A="55 68.75 82.5"; E="82.5 103.125 123.75"
K="0 0 0"; S="0.5 0.5 0.5"; T="0.5 0 0"
# knock k every $1 s: velocity digit table (8 digits) chosen by section, place table likewise
KN(){ # period, vel tables a b c d (8 digits), place tables a b c d (8 digits of 0..2), place p
echo "st(0,floor(t/$1));st(1,t-ld(0)*$1);st(5,mod(floor(ld(0)/16),4));st(6,mod(ld(0),8));
st(2,mod(floor(if(eq(ld(5),0),$2,if(eq(ld(5),1),$3,if(eq(ld(5),2),$4,$5)))/pow(10,ld(6))),10)/9);
st(3,mod(floor(if(eq(ld(5),0),$6,if(eq(ld(5),1),$7,if(eq(ld(5),2),$8,$9)))/pow(10,ld(6))),10));
st(8,0.009-0.007*ld(2));eq(ld(3),${10})*pow(ld(2),2)*(lt(ld(1),ld(8))*(1-cos(2*PI*ld(1)/ld(8)))/2+0.9*ld(2)*(random(9)*2-1)*exp(-ld(1)*500))"
}
LO="1 91919393 92739192 95929391 93919895 00200100 01200210 20100200 00120001"
HI="0.6 31615171 51813161 71315191 91713151 11011201 21101101 12011021 10211201"
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=360:exprs='$(KN $LO 0)|$(KN $LO 0)|$(KN $LO 1)|$(KN $LO 1)|$(KN $LO 2)|$(KN $LO 2)'[xl];
aevalsrc=s=48000:d=360:exprs='$(KN $HI 0)|$(KN $HI 0)|$(KN $HI 1)|$(KN $HI 1)|$(KN $HI 2)|$(KN $HI 2)'[xh];
aevalsrc=s=4000:d=2.4:exprs='$(room $A $K $EL 4)|$(room $A $K $ER 4)|$(room $A $S $EL 4)|$(room $A $S $ER 4)|$(room $A $T $EL 4)|$(room $A $T $ER 4)',aresample=48000[irl];
aevalsrc=s=4000:d=2.2:exprs='$(room $E $K $ER 4.5)|$(room $E $K $EL 4.5)|$(room $E $S $ER 4.5)|$(room $E $S $EL 4.5)|$(room $E $T $ER 4.5)|$(room $E $T $EL 4.5)',aresample=48000[irh];
[xl]asplit[xl][xld];[xh]asplit[xh][xhd];
[xl][irl]afir=irnorm=-1:irfmt=input,pan=stereo|c0=c0+c2+c4|c1=c1+c3+c5[rl];
[xld]pan=stereo|c0=c0+c2+c4|c1=c1+c3+c5,highpass=f=800,volume=0.25[dl];
[rl][dl]amix=inputs=2:normalize=0,volume=0.5,silenceremove=stop_periods=-1:stop_threshold=-30dB:stop_duration=0:stop_silence=0:detection=rms:window=0.02:stop_mode=all,asetpts=N/SR/TB[low];
[xh][irh]afir=irnorm=-1:irfmt=input,pan=stereo|c0=c0+c2+c4|c1=c1+c3+c5[rh];
[xhd]pan=stereo|c0=c0+c2+c4|c1=c1+c3+c5,highpass=f=1500,volume=0.3[dh];
[rh][dh]amix=inputs=2:normalize=0,volume=0.4,silenceremove=stop_periods=-1:stop_threshold=-32dB:stop_duration=0:stop_silence=0:detection=rms:window=0.015:stop_mode=all,asetpts=N/SR/TB[high];
[low][high]amix=inputs=2:weights=1 0.8:normalize=0:duration=shortest,
equalizer=f=1000:t=o:w=2:g=4,highshelf=f=1500:g=9,acompressor=threshold=0.4:ratio=2:attack=5:release=120,alimiter=level=0:limit=0.85,volume=0.7,atrim=0:140,afade=t=in:d=0.5,afade=t=out:st=130:d=10" "$@"
