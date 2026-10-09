#!/bin/bash
# Mix "ears" for a rendered file: RMS per band (dBFS) + stereo side/mid ratio.
# usage: scripts/analyze.sh file   ->  sub=-30 low=-22 mid=-20 hmid=-28 air=-40 side/mid=-9dB
f="$1"
ch=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 "$f")
ffmpeg -hide_banner -nostats -i "$f" -filter_complex "
[0:a]asplit=6[a][b][c][d][e][s];
[a]lowpass=f=60,lowpass=f=60,astats=measure_overall=RMS_level:measure_perchannel=0[o1];
[b]highpass=f=60,highpass=f=60,lowpass=f=250,lowpass=f=250,astats=measure_overall=RMS_level:measure_perchannel=0[o2];
[c]highpass=f=250,highpass=f=250,lowpass=f=2000,lowpass=f=2000,astats=measure_overall=RMS_level:measure_perchannel=0[o3];
[d]highpass=f=2000,highpass=f=2000,lowpass=f=6000,lowpass=f=6000,astats=measure_overall=RMS_level:measure_perchannel=0[o4];
[e]highpass=f=6000,highpass=f=6000,astats=measure_overall=RMS_level:measure_perchannel=0[o5];
[s]aformat=channel_layouts=stereo,asplit[m0][s0];[m0]pan=mono|c0=0.5*c0+0.5*c1,astats=measure_overall=RMS_level:measure_perchannel=0[o6];
[s0]pan=mono|c0=0.5*c0-0.5*c1,astats=measure_overall=RMS_level:measure_perchannel=0[o7]" \
 -map "[o1]" -f null - -map "[o2]" -f null - -map "[o3]" -f null - -map "[o4]" -f null - -map "[o5]" -f null - -map "[o6]" -f null - -map "[o7]" -f null - 2>&1 |
 awk '/RMS level dB/{match($0,/Parsed_astats_[0-9]+/);k[++i]=substr($0,RSTART+14,RLENGTH-14)+0;r[i]=$NF} END{for(a=1;a<=i;a++){m=0;for(b=1;b<=i;b++)if(k[b]<k[a])m++;v[m+1]=r[a]};printf "sub=%.0f low=%.0f mid=%.0f hmid=%.0f air=%.0f side/mid=%s\n",v[1],v[2],v[3],v[4],v[5],(ch==1?"mono":sprintf("%.0fdB",v[7]-v[6]))}' ch="$ch"
