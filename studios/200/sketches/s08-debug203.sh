#!/bin/sh
# hahlyricalsustaineveningawaken
# bibtwistertymbalsbustledoxygen
# palsummersdynastyswallowbyword
# impmusicaltympanitwelftheyelid
# peaovationpursuedlyricalturret
# hamhymnalsoutsideawkwardsunset
# ampdwindlerubbishdynamicbubble
# bibdynamicoutcomeharvest  void
#
# 203 — WHISPER DOWN THE LANE (a round for seven telephones)
#
# The eight lines above are GSM frames (see 201): each is decoded 50 times until the
# decoder settles, and its last 160 samples are held (aloop): a pitch at
# rate/160 Hz with the colour of its words. Seven of them, at rates 160 x frequency,
# play a pentatonic tune in A (just: 220 264 293.3 330 396 440 528) over a bass of
# "dynamic"(55 Hz) and "dwindle"(110 Hz). The tune is four bars of eighth notes kept
# as four digit tables, read right to left: bar 1 = 4043211, bar 2 = 43456,
# bar 3 = 67065433, bar 4 = 12345 (digit = which line sings, 0 = rest).
#
# Then the tune is whispered down a lane of telephones, inside this one command:
# each generation is encoded, decoded by a loopback decoder (-dec), delayed one bar,
# and handed to the next codec:
#   G.723.1 -> RealAudio 14.4 (with bit errors) -> Nellymoser -> Speex -> G.726 at
#   2 bits/sample -> DFPWM (1 bit) -> RFC 3389 comfort noise.
# Every copy enters a bar after the last, so the lane is a round (any bar of the
# tune sits on any other: it is all one pentatonic chord), and every copy is the
# previous copy's mishearing. The singer stops after ten choruses; the lane keeps
# passing it on until only comfort noise is left: the shape of the tune with no tune.
ffmpeg -hide_banner -y \
 -stream_loop 49 -f gsm -sample_rate 35200 -i "subfile,,start,142,end,175,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 42240 -i "subfile,,start,10,end,43,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 46933 -i "subfile,,start,76,end,109,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 52800 -i "subfile,,start,109,end,142,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 63360 -i "subfile,,start,142,end,175,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 70400 -i "subfile,,start,10,end,43,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 84480 -i "subfile,,start,76,end,109,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 8800 -i "subfile,,start,241,end,274,,:$0" \
 -stream_loop 49 -f gsm -sample_rate 17600 -i "subfile,,start,208,end,241,,:$0" \
 -filter_complex "
 [0]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono[w1];
 aevalsrc=exprs='st(0,ld(0)+0.2*(eq(mod(floor(if(eq(mod(floor(t/2.4),4),0),4043211,if(eq(mod(floor(t/2.4),4),1),43456,if(eq(mod(floor(t/2.4),4),2),67065433,12345)))/pow(10,mod(floor(t/0.3),8))),10),1)*lt(mod(t,0.3),0.26)*lt(t,96)-ld(0)))':s=1000:d=100,aresample=48000[c1];
 [w1][c1]amultiply,volume=0.16[v1];
 [1]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono[w2];
 aevalsrc=exprs='st(0,ld(0)+0.2*(eq(mod(floor(if(eq(mod(floor(t/2.4),4),0),4043211,if(eq(mod(floor(t/2.4),4),1),43456,if(eq(mod(floor(t/2.4),4),2),67065433,12345)))/pow(10,mod(floor(t/0.3),8))),10),2)*lt(mod(t,0.3),0.26)*lt(t,96)-ld(0)))':s=1000:d=100,aresample=48000[c2];
 [w2][c2]amultiply,volume=0.16[v2];
 [2]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono[w3];
 aevalsrc=exprs='st(0,ld(0)+0.2*(eq(mod(floor(if(eq(mod(floor(t/2.4),4),0),4043211,if(eq(mod(floor(t/2.4),4),1),43456,if(eq(mod(floor(t/2.4),4),2),67065433,12345)))/pow(10,mod(floor(t/0.3),8))),10),3)*lt(mod(t,0.3),0.26)*lt(t,96)-ld(0)))':s=1000:d=100,aresample=48000[c3];
 [w3][c3]amultiply,volume=0.16[v3];
 [3]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono[w4];
 aevalsrc=exprs='st(0,ld(0)+0.2*(eq(mod(floor(if(eq(mod(floor(t/2.4),4),0),4043211,if(eq(mod(floor(t/2.4),4),1),43456,if(eq(mod(floor(t/2.4),4),2),67065433,12345)))/pow(10,mod(floor(t/0.3),8))),10),4)*lt(mod(t,0.3),0.26)*lt(t,96)-ld(0)))':s=1000:d=100,aresample=48000[c4];
 [w4][c4]amultiply,volume=0.16[v4];
 [4]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono[w5];
 aevalsrc=exprs='st(0,ld(0)+0.2*(eq(mod(floor(if(eq(mod(floor(t/2.4),4),0),4043211,if(eq(mod(floor(t/2.4),4),1),43456,if(eq(mod(floor(t/2.4),4),2),67065433,12345)))/pow(10,mod(floor(t/0.3),8))),10),5)*lt(mod(t,0.3),0.26)*lt(t,96)-ld(0)))':s=1000:d=100,aresample=48000[c5];
 [w5][c5]amultiply,volume=0.16[v5];
 [5]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono[w6];
 aevalsrc=exprs='st(0,ld(0)+0.2*(eq(mod(floor(if(eq(mod(floor(t/2.4),4),0),4043211,if(eq(mod(floor(t/2.4),4),1),43456,if(eq(mod(floor(t/2.4),4),2),67065433,12345)))/pow(10,mod(floor(t/0.3),8))),10),6)*lt(mod(t,0.3),0.26)*lt(t,96)-ld(0)))':s=1000:d=100,aresample=48000[c6];
 [w6][c6]amultiply,volume=0.16[v6];
 [6]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono[w7];
 aevalsrc=exprs='st(0,ld(0)+0.2*(eq(mod(floor(if(eq(mod(floor(t/2.4),4),0),4043211,if(eq(mod(floor(t/2.4),4),1),43456,if(eq(mod(floor(t/2.4),4),2),67065433,12345)))/pow(10,mod(floor(t/0.3),8))),10),7)*lt(mod(t,0.3),0.26)*lt(t,96)-ld(0)))':s=1000:d=100,aresample=48000[c7];
 [w7][c7]amultiply,volume=0.16[v7];
 [7]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono,aeval='val(0)*clip(t/6,0,1)*clip((99-t)/3,0,1)',volume=0.35[b1];
 [8]atrim=start_sample=6400:end_sample=6560,asetpts=N/SR/TB,aloop=loop=-1:size=160,atrim=end=100,aresample=48000,aformat=channel_layouts=mono,aeval='val(0)*clip((t-9.6)/9.6,0,1)*clip((99-t)/3,0,1)*(0.6+0.4*cos(2*PI*t/2.4))',volume=0.12[b2];
 [v1][v2][v3][v4][v5][v6][v7][b1][b2]amix=inputs=9:normalize=0,highpass=f=30,atrim=0:8,asplit[g0][e0]" \
 -map "[e0]" -c:a g723_1 -ar 8000 -f null - -dec 0:0 \
 -filter_complex "[dec:0]adelay=2400,asplit[g1][e1]" -map "[e1]" -c:a real_144 -ar 8000 -bsf:a noise=amount=400 -f null - -dec 1:0 \
 -filter_complex "[dec:1]adelay=2400,asplit[g2][e2]" -map "[e2]" -c:a nellymoser -ar 8000 -f null - -dec 2:0 \
 -filter_complex "[dec:2]adelay=2400,asplit[g3][e3]" -map "[e3]" -c:a libspeex -ar 8000 -f null - -dec 3:0 \
 -filter_complex "[dec:3]adelay=2400,asplit[g4][e4]" -map "[e4]" -c:a g726 -ar 8000 -code_size 2 -f null - -dec 4:0 \
 -filter_complex "[dec:4]adelay=2400,asplit[g5][e5]" -map "[e5]" -c:a dfpwm -ar 8000 -f null - -dec 5:0 \
 -filter_complex "[dec:5]adelay=2400,asplit[g6][e6]" -map "[e6]" -c:a comfortnoise -ar 8000 -f null - -dec 6:0 \
 -filter_complex "[dec:6]adelay=2400[g7];
 [g0]aresample=48000,pan=stereo|c0=1.00*c0|c1=1.00*c0[p0];
 [g1]aresample=48000,pan=stereo|c0=0.90*c0|c1=0.50*c0[p1];
 [g2]aresample=48000,pan=stereo|c0=0.47*c0|c1=0.85*c0[p2];
 [g3]aresample=48000,pan=stereo|c0=0.80*c0|c1=0.28*c0[p3];
 [g4]aresample=48000,pan=stereo|c0=0.26*c0|c1=0.75*c0[p4];
 [g5]aresample=48000,pan=stereo|c0=0.70*c0|c1=0.14*c0[p5];
 [g6]aresample=48000,pan=stereo|c0=0.14*c0|c1=0.70*c0[p6];
 [g7]aresample=48000,pan=stereo|c0=2.00*c0|c1=2.00*c0[p7];
 [p0][p1][p2][p3][p4][p5][p6][p7]amix=inputs=8:normalize=0,alimiter=limit=0.8:attack=3:release=80,afade=t=out:st=112:d=6[out]" -map "[out]" "$@"
