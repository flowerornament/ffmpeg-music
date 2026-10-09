#!/bin/sh
# 511 — Eigenvector
# The record's coda, and its argument in one minute. The corner knock from 510, in the same
# A-major room, heard again and again — but each time through the room squared:
#   IR, IR^2, IR^4, IR^8, IR^16, IR^32, IR^64
# (each power made by convolving the previous one with itself, afir fed the same stream
# twice, then renormalised). Lucier's I Am Sitting in a Room is the power method; squaring
# is the power method in a hurry: seven steps reach the 64th re-recording. A knock becomes a
# chord becomes a few partials becomes what the room, heard from these two ears, keeps when
# it has been applied 64 times: its dominant eigenvector. One every nine seconds.
# (Rendered: the knock's A major thins to C# and B, and at IR^64 what is left is B4 —
# the 9th harmonic of 55 Hz — over E4. The room ends the record on its dominant.)
room(){ # rx ry rz (source in the corner)
echo "st(4,0);st(0,1);while(lt(ld(0),30),st(3,ld(0)*55);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$1)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(3,ld(0)*68.75);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$2)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(3,ld(0)*82.5);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$3)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,0);while(lt(ld(0),7),st(1,0);while(lt(ld(1),6),st(2,0);while(lt(ld(2),5),st(5,gt(ld(0),0)+gt(ld(1),0)+gt(ld(2),0));st(3,sqrt(pow(ld(0)*55,2)+pow(ld(1)*68.75,2)+pow(ld(2)*82.5,2)));st(4,ld(4)+gte(ld(5),2)*pow(0.45,ld(5)-1)*cos(PI*ld(0)*$1)*cos(PI*ld(1)*$2)*cos(PI*ld(2)*$3)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));0.03*ld(4)"
}
N="atrim=0:8,alimiter=level=1:limit=0.5:attack=5:release=800,afade=t=out:st=6:d=2"   # renormalise (auto-level), keep 8 s
SQ="asplit[A][B];[A][B]afir=irnorm=2:maxir=10"                         # convolve with itself
P(){ echo "atrim=0:8,afade=t=in:d=0.005,afade=t=out:st=5.5:d=2.5,adelay=$(( $1 * 9 + 1 ))s:all=1"; }
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=4000:d=8:exprs='$(room 0.11 0.07 0.19)|$(room 0.17 0.13 0.05)',aresample=48000,$N,asplit[g0][q0];
[q0]asplit[a0][b0];[a0][b0]afir=irnorm=2:maxir=10,$N,asplit[g1][q1];
[q1]asplit[a1][b1];[a1][b1]afir=irnorm=2:maxir=10,$N,asplit[g2][q2];
[q2]asplit[a2][b2];[a2][b2]afir=irnorm=2:maxir=10,$N,asplit[g3][q3];
[q3]asplit[a3][b3];[a3][b3]afir=irnorm=2:maxir=10,$N,asplit[g4][q4];
[q4]asplit[a4][b4];[a4][b4]afir=irnorm=2:maxir=10,$N,asplit[g5][q5];
[q5]asplit[a5][b5];[a5][b5]afir=irnorm=2:maxir=10,$N[g6];
[g0]$(P 0)[h0];[g1]$(P 1)[h1];[g2]$(P 2)[h2];[g3]$(P 3)[h3];[g4]$(P 4)[h4];[g5]$(P 5)[h5];
[g6]atrim=0:8,afade=t=in:d=0.005,afade=t=out:st=4:d=4,adelay=55s:all=1[h6];
[h0][h1][h2][h3][h4][h5][h6]amix=inputs=7:normalize=0,volume=0.33,alimiter=level=0:limit=0.8,apad=pad_dur=3" "$@"
