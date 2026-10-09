#!/bin/sh
# 501 — Power Iteration
# Lucier's "I Am Sitting in a Room" is the power method: apply the same matrix again and
# again and only its dominant eigenvectors survive. Here it happens inside one command.
# THE ROOM is built from math: the modal sum of a rectangular room whose axial fundamentals
# are 55 : 68.75 : 82.5 Hz (A, C#, E) — axial modes up to ~4 kHz, tangential (x.5) and
# oblique (x.25) modes below ~700 Hz, damping rising with frequency, two ears at two
# points (mode shapes cos(l*pi*x) differ per ear: the stereo field is the geometry).
# The room is heavily damped on purpose: damping is the convergence rate. A live room
# collapses to its chord in one pass; this one takes twelve.
# THE VOICE is the ffmpeg manual reading itself: the bytes of the afir / aformat /
# afreqshift pages read as unsigned 8-bit samples at 55 Hz, upsampled with a zero-length
# resampler filter, so each letter is one raised-cosine glottal pulse (~18 ms, phoneme
# rate), spaces are deep troughs, words are syllables.
# THE FORM: generations g0..g12, each = previous convolved with the room and renormalised
# (dynaudnorm). The text keeps advancing: the k-th 8-second stretch of reading is heard
# from generation k, so the words go forward while the room eats them deeper.
# What the iteration finds is not the triad it was tuned to: the voice's A gives way to
# C#, then to C# G# B (5th, 15/2th, 9th harmonics of 55) — the room's own chord.
room(){ # damping, ear position x y z
echo "st(4,0);st(0,1);while(lt(ld(0),70),st(3,ld(0)*55);st(4,ld(4)+cos(PI*ld(0)*$2)*exp(-t*($1+ld(3)/80))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,1);while(lt(ld(0),56),st(3,ld(0)*68.75);st(4,ld(4)+cos(PI*ld(0)*$3)*exp(-t*($1+ld(3)/80))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,1);while(lt(ld(0),47),st(3,ld(0)*82.5);st(4,ld(4)+cos(PI*ld(0)*$4)*exp(-t*($1+ld(3)/80))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,0);while(lt(ld(0),8),st(1,0);while(lt(ld(1),7),st(2,0);while(lt(ld(2),6),st(5,gt(ld(0),0)+gt(ld(1),0)+gt(ld(2),0));st(3,sqrt(pow(ld(0)*55,2)+pow(ld(1)*68.75,2)+pow(ld(2)*82.5,2)));st(4,ld(4)+gte(ld(5),2)*pow(0.5,ld(5)-1)*cos(PI*ld(0)*$2)*cos(PI*ld(1)*$3)*cos(PI*ld(2)*$4)*exp(-t*($1+ld(3)/80))*sin(2*PI*ld(3)*t));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));0.05*ld(4)"
}
N="dynaudnorm=f=200:g=11:p=0.5:m=30"       # Lucier's level knob, between generations
P="afir=irnorm=1,$N"                         # one pass through the room
# generation k is heard from 8k s to 8k+8 s (+1 s overlap each side)
W(){ echo "atrim=start=$(($1*8-1)):end=$(($1*8+9)),asetpts=PTS-STARTPTS,afade=t=in:d=1.5,afade=t=out:st=8.5:d=1.5,adelay=$(($1*8-1))s:all=1"; }
ffmpeg -hide_banner -y -f u8 -ar 55 -ac 1 -i "$(dirname "$0")/../found/afir-manual-page" -filter_complex "
aevalsrc=s=12000:d=1.2:exprs='$(room 9 0.31 0.53 0.17)|$(room 9 0.37 0.47 0.23)',aresample=48000,asplit=12[r1][r2][r3][r4][r5][r6][r7][r8][r9][r10][r11][r12];
[0:a]aresample=48000:filter_size=0,highpass=f=30,pan=stereo|c0=c0|c1=c0,$N,asplit[g0][s0];
[s0][r1]$P,asplit[g1][s1];[s1][r2]$P,asplit[g2][s2];[s2][r3]$P,asplit[g3][s3];[s3][r4]$P,asplit[g4][s4];
[s4][r5]$P,asplit[g5][s5];[s5][r6]$P,asplit[g6][s6];[s6][r7]$P,asplit[g7][s7];[s7][r8]$P,asplit[g8][s8];
[s8][r9]$P,asplit[g9][s9];[s9][r10]$P,asplit[g10][s10];[s10][r11]$P,asplit[g11][s11];[s11][r12]$P[g12];
[g0]atrim=end=9,afade=t=out:st=7.5:d=1.5[h0];
[g1]$(W 1)[h1];[g2]$(W 2)[h2];[g3]$(W 3)[h3];[g4]$(W 4)[h4];[g5]$(W 5)[h5];
[g6]$(W 6)[h6];[g7]$(W 7)[h7];[g8]$(W 8)[h8];[g9]$(W 9)[h9];
[g10]$(W 10)[h10];[g11]$(W 11)[h11];
[g12]atrim=start=95,asetpts=PTS-STARTPTS,afade=t=in:d=1.5,afade=t=out:st=10:d=17,adelay=95s:all=1[h12];
[h0][h1][h2][h3][h4][h5][h6][h7][h8][h9][h10][h11][h12]amix=inputs=13:normalize=0:duration=longest,
highshelf=f=1800:g=7,volume=1.3,acompressor=threshold=0.3:ratio=2:attack=20:release=300,alimiter=level=0:limit=0.7" "$@"
