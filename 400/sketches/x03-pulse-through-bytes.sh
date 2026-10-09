#!/bin/sh
# impulse train (melody) convolved with 4096 bytes of /bin/ls as IR -> bytes tuned to any pitch.
# Instructive failure: that region of /bin/ls is all zeros (binaries here are ~69% zero bytes), so
# the IR is pure DC and the result is near-silent. Led to mapping the dylib symbol tables instead.
ffmpeg -hide_banner -y -f u8 -ar 48000 -ac 1 -i /bin/ls -filter_complex "
[0]atrim=start_sample=60000:end_sample=64096,asetpts=N/SR/TB[ir];
aevalsrc=s=48000:d=12:exprs='st(1,floor(t*3));st(2,mod(floor(4031203/pow(10,mod(ld(1),7))),10));
 st(3,110*pow(2,(floor((12*(ld(2)+5)+5)/7)-9)/12));
 st(4,ld(0));st(0,mod(ld(0)+ld(3)/48000,1));lt(ld(0),ld(4))'[imp];
[imp][ir]afir=irnorm=-1,highpass=f=30,volume=0.05,alimiter" "$@"
