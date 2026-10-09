#!/bin/sh
# diatonic-live — the Diatonic Machine as a playable instrument.
# One ffmpeg command. Knobs are registers: a constant 1.0 signal through a named
# `volume` filter, merged in as an extra channel that the synth expression reads with
# val(i). ffmpeg's own stdin console ('c' + "volume@degree -1 volume 3") turns them live.
# Pad: 4-voice diatonic 7th chords with folded voice leading (phase accumulators, so chord
# changes glide without clicks). Arp: Barbieri-style mod(3*step,5) chord-tone row,
# density-gated. Bass: root on the beat. 112 bpm.
#
# knob  name     target          command min max default step  dec inc
# @knob degree   volume@degree   volume  0   6   0       1     ,   .
# @knob mode     volume@mode     volume  0   6   5       1     m   M
# @knob density  volume@density  volume  0   1   0.6     0.1   [   ]
# @knob tone     lowpass@tone    f       300 12000 2500  1.25* -   =
# @keys degree   1234567
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=1:s=48000:d=3600,aformat=sample_fmts=dbl,asplit=3[k0][k1][k2];
[k0]volume@degree=volume=0:precision=double[d];
[k1]volume@mode=volume=5:precision=double[m];
[k2]volume@density=volume=0.6:precision=double[g];
[d][m][g]amerge=inputs=3,
aeval=channel_layout=stereo:exprs='
 st(8,round(val(0)));st(9,round(val(1)));
 0.055*(
  st(7,floor((12*(ld(8)+0+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(0,mod(ld(0)+220*pow(2,(mod(ld(7)+17,12)-5)/12)/48000,1));sin(2*PI*ld(0))+0.3*sin(4*PI*ld(0))+
  st(7,floor((12*(ld(8)+2+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(1,mod(ld(1)+220*pow(2,(mod(ld(7)+13,12)-1)/12)/48000,1));sin(2*PI*ld(1))+0.3*sin(4*PI*ld(1))+
  st(7,floor((12*(ld(8)+4+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(2,mod(ld(2)+220*pow(2,(mod(ld(7)+9,12)+3)/12)/48000,1));sin(2*PI*ld(2))+0.3*sin(4*PI*ld(2))+
  st(7,floor((12*(ld(8)+6+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(3,mod(ld(3)+220*pow(2,(mod(ld(7)+5,12)+7)/12)/48000,1));sin(2*PI*ld(3))+0.3*sin(4*PI*ld(3)))
 +st(4,floor(t*7.466667))*0+st(5,t-ld(4)/7.466667)*0
 +st(7,floor((12*(ld(8)+2*mod(3*ld(4),5)+7*mod(floor(ld(4)/5),2)+ld(9))+5)/7)-floor((12*ld(9)+5)/7))*0
 +0.13*lt(mod(sin(ld(4)*12.9898)*43758.5453,1),val(2))*exp(-ld(5)*16)*(1-ld(5)*7.466667)*sin(2*PI*440*pow(2,ld(7)/12)*ld(5)+1.2*exp(-ld(5)*12)*sin(4*PI*440*pow(2,ld(7)/12)*ld(5)))
 +st(7,floor((12*(ld(8)+ld(9))+5)/7)-floor((12*ld(9)+5)/7))*0
 +eq(mod(ld(4),4),0)*0.28*exp(-ld(5)*6)*(1-ld(5)*7.466667)*sin(2*PI*55*pow(2,ld(7)/12)*ld(5)+0.8*exp(-ld(5)*9)*sin(2*PI*55*pow(2,ld(7)/12)*ld(5)))
 +eq(mod(ld(4),4),0)*0.4*exp(-ld(5)*22)*sin(2*PI*(45+140*exp(-ld(5)*40))*ld(5))
 |
 st(8,round(val(0)));st(9,round(val(1)));
 0.055*(
  st(7,floor((12*(ld(8)+0+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(0,mod(ld(0)+1.004*220*pow(2,(mod(ld(7)+17,12)-5)/12)/48000,1));sin(2*PI*ld(0))+0.3*sin(4*PI*ld(0))+
  st(7,floor((12*(ld(8)+2+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(1,mod(ld(1)+1.004*220*pow(2,(mod(ld(7)+13,12)-1)/12)/48000,1));sin(2*PI*ld(1))+0.3*sin(4*PI*ld(1))+
  st(7,floor((12*(ld(8)+4+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(2,mod(ld(2)+1.004*220*pow(2,(mod(ld(7)+9,12)+3)/12)/48000,1));sin(2*PI*ld(2))+0.3*sin(4*PI*ld(2))+
  st(7,floor((12*(ld(8)+6+ld(9))+5)/7)-floor((12*ld(9)+5)/7));st(3,mod(ld(3)+1.004*220*pow(2,(mod(ld(7)+5,12)+7)/12)/48000,1));sin(2*PI*ld(3))+0.3*sin(4*PI*ld(3)))
 +st(4,floor(t*7.466667))*0+st(5,t-ld(4)/7.466667)*0
 +st(7,floor((12*(ld(8)+2*mod(3*ld(4)+2,5)+7*mod(floor(ld(4)/5),2)+ld(9))+5)/7)-floor((12*ld(9)+5)/7))*0
 +0.13*lt(mod(sin(ld(4)*78.233)*12543.31,1),val(2))*exp(-ld(5)*16)*(1-ld(5)*7.466667)*sin(2*PI*440*pow(2,ld(7)/12)*ld(5)+1.2*exp(-ld(5)*12)*sin(4*PI*440*pow(2,ld(7)/12)*ld(5)))
 +st(7,floor((12*(ld(8)+ld(9))+5)/7)-floor((12*ld(9)+5)/7))*0
 +eq(mod(ld(4),4),0)*0.28*exp(-ld(5)*6)*(1-ld(5)*7.466667)*sin(2*PI*55*pow(2,ld(7)/12)*ld(5)+0.8*exp(-ld(5)*9)*sin(2*PI*55*pow(2,ld(7)/12)*ld(5)))
 +eq(mod(ld(4),4),0)*0.4*exp(-ld(5)*22)*sin(2*PI*(45+140*exp(-ld(5)*40))*ld(5))',
aformat=sample_fmts=flt:channel_layouts=stereo,lowpass@tone=f=2500,aecho=0.8:0.8:401.8|267.9:0.3|0.25,alimiter=limit=0.9:level=0
" "$@"
