#!/bin/sh
# 303 — Scene Changes (PHI No. 3)
# A harp made of video filters.
#  strings  each partial is struck on one video frame and `lagfun` — the afterimage filter,
#           persistence of vision — lets it decay: the video afterglow is the string's ring.
#  harmony  an otonal ladder: every chord is 4:5:6:8 on harmonic k of 46.875 Hz, i.e. bins
#           4k 5k 6k 8k with the bass on bin k: k = 6 (I), 8 (IV), 9 (V), 7 (the harmonic-seventh
#           major chord), 10, 5, 11 (an 11-limit major chord), 12. Pure just triads, tonics
#           wandering up and down the overtone series.
#  motion   minterpolate (motion-compensated interpolation) carries the partials between
#           chords. Its scene-change detector judges harmonic distance: the left eye
#           (scd_threshold 0.5) cuts between chords that share no partial and glides between
#           neighbours; the right eye never cuts. Remote modulations are hard cuts on the left
#           and slow bends on the right — the stereo field splits exactly there. Strings
#           plucked while they bend ring at the pitch where they were struck.
#  rhythm   117.19 bpm, a sixteenth = 6 video frames. Upper partials strum a Euclidean
#           E(n,16) whose n rises 3 -> 9 and falls; the strum spreads over 4 frames from low to
#           high (left) and high to low (right); the bass is struck on quarter notes.
#           The ensemble learns to swing: odd sixteenths drift 0 -> 1 -> 2 frames late
#           (50% -> 58% -> 67%) over the first minute.
#  air      the image stretched x4 (two octaves up) is struck too: bells over the harp.
F=46.875
# chord k-index by keyframe pair; bass|4k|5k|6k|8k packed as 2-digit fields
CH="st(9,floor(N/2));if(eq(ld(9),0),0624303648,if(eq(ld(9),1),0832404864,if(eq(ld(9),2),0936455472,if(eq(ld(9),3),0624303648,
if(eq(ld(9),4),0728354256,if(eq(ld(9),5),1040506080,if(eq(ld(9),6),0520253040,if(eq(ld(9),7),0936455472,
if(eq(ld(9),8),0624303648,if(eq(ld(9),9),1144556688,if(eq(ld(9),10),0832404864,if(eq(ld(9),11),0728354256,
if(eq(ld(9),12),1248607296,if(eq(ld(9),13),0936455472,if(eq(ld(9),14),0624303648,0624303648)))))))))))))))"
# arrive / depart times: hold 2 bars, move 1 bar (bar = 2.048 s); the last real chord rings out
TK="if(lt(N,30),floor(N/2)*6.144+if(mod(N,2),4.096,0),if(eq(N,30),92.16+8,if(eq(N,31),120,140)))"
DRAW="st(0,H-1-Y);st(8,$CH);
st(1,mod(floor(ld(8)/100000000),100));st(2,mod(floor(ld(8)/1000000),100));st(3,mod(floor(ld(8)/10000),100));
st(4,mod(floor(ld(8)/100),100));st(5,mod(ld(8),100));
st(6,1.5*exp(-pow((ld(0)-ld(1))/1.2,2))+0.7*exp(-pow((ld(0)-2*ld(1))/1.2,2)));st(7,1);
while(lte(ld(7),5),st(6,ld(6)+(exp(-pow((ld(0)-ld(2)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.2,2))
 +exp(-pow((ld(0)-ld(4)*ld(7))/1.2,2))+0.8*exp(-pow((ld(0)-ld(5)*ld(7))/1.2,2)))/ld(7));st(7,ld(7)+1));
min(255,180*ld(6))"
PICK="p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))"
APICK="p(X,Y)*gte(p(X,Y),p(X,Y-1))*gt(p(X,Y),p(X,Y+1))*0.45"
# strike: ld(1) bin, ld(2) sixteenth index, ld(3) frame within it, ld(4) strum delay, ld(5) swing, ld(6) Euclid n
SL="st(1,max(H-1-Y,1));st(2,floor(N/6));st(3,N-6*ld(2));st(4,floor(3.99*clip((log(ld(1))/log(2)-3.5)/4,0,1)));
st(5,round(2*clip((T-8)/50,0,1))*mod(ld(2),2));st(6,round(3+6*clip(T/70,0,1)-5*clip((T-80)/30,0,1)));
p(X,Y)*0.24*if(lt(ld(1),14),eq(mod(ld(2),4),0)*eq(ld(3),0),lt(mod((ld(2)+floor(ld(2)/16))*ld(6),16),ld(6))*eq(ld(3),min(5,ld(4)+ld(5))))"
SR="st(1,max(H-1-Y,1));st(2,floor(N/6));st(3,N-6*ld(2));st(4,3-floor(3.99*clip((log(ld(1))/log(2)-3.5)/4,0,1)));
st(5,round(2*clip((T-8)/50,0,1))*mod(ld(2),2));st(6,round(3+6*clip(T/70,0,1)-5*clip((T-80)/30,0,1)));
p(X,Y)*0.24*if(lt(ld(1),14),eq(mod(ld(2),4),0)*eq(ld(3),0),lt(mod((ld(2)+floor(ld(2)/16))*ld(6),16),ld(6))*eq(ld(3),min(5,ld(4)+ld(5))))"
PHASE="255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)"
SYN="spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=32x2049:r=1:d=33,format=gray,geq=lum='$DRAW',setpts='($TK)/TB',split[k1][k2];
[k1]minterpolate=fps=$F:mi_mode=mci:scd=fdiff:scd_threshold=0.5:me_mode=bidir:me=esa:search_param=32,format=gray,crop=1:2049:16:0,
 geq=lum='$PICK',split[bL][aL];[aL]scale=1:8196:flags=neighbor,crop=1:2049:0:6147,geq=lum='$APICK'[sL];
 [bL][sL]blend=all_mode=addition,geq=lum='$SL',lagfun=decay=0.85[mL];
[k2]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bidir:me=esa:search_param=32,format=gray,crop=1:2049:16:0,
 geq=lum='$PICK',split[bR][aR];[aR]scale=1:8196:flags=neighbor,crop=1:2049:0:6147,geq=lum='$APICK'[sR];
 [bR][sR]blend=all_mode=addition,geq=lum='$SR',lagfun=decay=0.85[mR];
color=c=black:s=1x2049:r=$F:d=130,format=gray,geq=lum='$PHASE',split[pL][pR];
[mL][pL]$SYN[l];[mR][pR]$SYN[r];
[l][r]join=inputs=2:channel_layout=stereo,atrim=0:118,asplit[dry][w];
aevalsrc=d=4:s=48000:exprs='(random(0)*2-1)*exp(-t*1.6)|(random(1)*2-1)*exp(-t*1.6)',lowpass=f=8000[ir];
[w]highpass=f=150[w2];[w2][ir]afir=dry=1:wet=1[wet];
[dry][wet]amix=inputs=2:weights=1 0.3:normalize=0,highpass=f=30,
 acompressor=threshold=0.1:ratio=2:attack=30:release=200,volume=1.1,alimiter=limit=0.89:level=0,
 afade=t=in:d=1,afade=t=out:st=108:d=10
" "$@"
