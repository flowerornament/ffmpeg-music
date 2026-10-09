#!/bin/sh
# overtone projection: drone x = band-limited impulse train on 55 Hz (closed-form Dirichlet), d = a tempered melody. The estimate (out_mode=e) can only contain the drone's harmonics: C -> 19th harmonic (1045 Hz), B -> 9th. Basis of 502.
F0=55; K=72
ffmpeg -hide_banner -filter_complex "
aevalsrc=s=48000:d=20:exprs='st(0,mod(ld(0)+$F0/48000,1));st(1,sin(PI*ld(0)));if(lt(abs(ld(1)),1e-6),1,(sin((2*$K+1)*PI*ld(0))/ld(1)-1)/(2*$K))*0.5'[x];
aevalsrc=s=48000:d=20:exprs='st(2,floor(t*4));st(3,mod(floor(3152030/pow(10,mod(ld(2),7))),10));st(4,220*pow(2,(floor((12*(ld(3)+5)+5)/7)-9)/12));st(5,mod(ld(5)+ld(4)/48000,1));0.3*(2*ld(5)-1)*exp(-mod(t,0.25)*3)'[d];
[x][d]anlms=order=1024:mu=0.02:out_mode=e" "$@"
