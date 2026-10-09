#!/bin/sh
# 002 — Diatonic Machine
# A minor (aeolian), 112 bpm, 36 bars. Harmony is computed, not stored:
#   scale degree d -> semitone   floor((12*(d+m)+5)/7) - floor((12*m+5)/7)   (m=5: aeolian)
#   chord on degree r            degrees r, r+2, r+4, r+6  (diatonic 7th chords)
#   progression                  digits of 44152630, read right to left: i iv VII III VI ii° v v
#                                (the descending-fifths cycle of "Autumn Leaves")
#   voice leading                each pad voice folds its pitch class into a fixed one-octave
#                                window, so voices move by the smallest step automatically
#   arpeggio (Barbieri)          chord tone index = mod(3*step,5): root,7th,3rd,9th,5th;
#                                octave flips every 5 steps against a 16-step bar (polymeter)
# Form: arp alone | +pad | +bass | +hats | breakdown (pad+arp) | all | out.
# Shell variables are notation only; what runs is one ffmpeg command.
BAR=2.142857   # seconds per 4/4 bar at 112 bpm
SPS=7.466667   # sixteenth notes per second
HEAD="st(0,floor(t/$BAR));st(1,mod(floor(44152630/pow(10,mod(ld(0),8))),10));st(9,mod(t,$BAR))"
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=78:exprs='$HEAD;
 gte(ld(0),4)*(1-pow(2*ld(9)/$BAR-1,10))*0.05*(
  st(2,floor((12*(ld(1)+0+5)+5)/7)-9);st(3,mod(ld(2)+17,12)-5);st(4,2*PI*220*pow(2,ld(3)/12)*t);sin(ld(4))+0.35*sin(2*ld(4))+0.15*sin(3*ld(4))+
  st(2,floor((12*(ld(1)+2+5)+5)/7)-9);st(3,mod(ld(2)+13,12)-1);st(4,2*PI*220*pow(2,ld(3)/12)*t);sin(ld(4))+0.35*sin(2*ld(4))+0.15*sin(3*ld(4))+
  st(2,floor((12*(ld(1)+4+5)+5)/7)-9);st(3,mod(ld(2)+9,12)+3);st(4,2*PI*220*pow(2,ld(3)/12)*t);sin(ld(4))+0.35*sin(2*ld(4))+0.15*sin(3*ld(4))+
  st(2,floor((12*(ld(1)+6+5)+5)/7)-9);st(3,mod(ld(2)+5,12)+7);st(4,2*PI*220*pow(2,ld(3)/12)*t);sin(ld(4))+0.35*sin(2*ld(4))+0.15*sin(3*ld(4)))',
 lowpass=f=1800,aphaser=in_gain=0.7:out_gain=0.9:delay=3:decay=0.4:speed=0.12,pan=stereo|c0=c0|c1=c0,adecorrelate[pad];

aevalsrc=s=48000:d=78:exprs='$HEAD;
 st(5,floor(t*$SPS));st(6,t-ld(5)/$SPS);
 st(2,ld(1)+2*mod(3*ld(5),5)+7*mod(floor(ld(5)/5),2));
 st(3,floor((12*(ld(2)+5)+5)/7)-9+12);st(4,220*pow(2,ld(3)/12));
 not(between(ld(0),24,25))*lt(mod(ld(5)*11,16),11)*0.16*exp(-ld(6)*16)*(1-ld(6)*$SPS)*
 sin(2*PI*ld(4)*ld(6)+1.3*exp(-ld(6)*12)*sin(2*PI*2*ld(4)*ld(6)))',
 aecho=in_gain=0.8:out_gain=0.85:delays=401.8|267.9:decays=0.38|0.3,pan=stereo|c0=0.8*c0|c1=0.6*c0,adecorrelate=stages=4[arp];

aevalsrc=s=48000:d=78:exprs='$HEAD;
 st(5,floor(t*$SPS));st(6,t-ld(5)/$SPS);
 st(3,floor((12*(ld(1)+5)+5)/7)-9-24);st(4,220*pow(2,ld(3)/12));
 gte(ld(0),8)*not(between(ld(0),24,27))*(
 mod(floor(18761/pow(2,mod(ld(5),16))),2)*0.32*exp(-ld(6)*7)*(1-ld(6)*$SPS)*sin(2*PI*ld(4)*ld(6)+0.9*exp(-ld(6)*9)*sin(2*PI*ld(4)*ld(6)))
 +eq(mod(ld(5),4),0)*0.55*exp(-ld(6)*22)*sin(2*PI*(45+140*exp(-ld(6)*40))*ld(6)))',
 lowpass=f=900,pan=stereo|c0=c0|c1=c0[bass];

aevalsrc=s=48000:d=78:exprs='$HEAD;
 st(5,floor(t*$SPS));st(6,t-ld(5)/$SPS);
 gte(ld(0),12)*not(between(ld(0),24,27))*lt(ld(0),36)*(0.5+0.5*eq(mod(ld(5),4),2))*
 0.12*exp(-ld(6)*(60-30*eq(mod(ld(5),4),2)))*(mod(sin(n*12.9898)*43758.5453,1)*2-1)',
 highpass=f=7000,pan=stereo|c0=0.6*c0|c1=c0[hats];

[pad][arp][bass][hats]amix=inputs=4:normalize=0,asplit[dry][w0];
aevalsrc=s=48000:d=3.5:exprs='(random(0)*2-1)*exp(-t*2.2)|(random(1)*2-1)*exp(-t*2.2)',lowpass=f=6000[ir];
[w0]highpass=f=300[w1];[w1][ir]afir[wet];
[dry][wet]amix=inputs=2:weights=1 0.35:normalize=0,
 acompressor=threshold=0.2:ratio=3:attack=5:release=120,alimiter=limit=0.9,afade=t=out:st=72:d=6
" "$@"
