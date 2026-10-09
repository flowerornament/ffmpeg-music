# l2: JI chorale (12 bars) x4 statements; magnitude of statement s through uspp/snow at qp Q_s
# raster: sr 20025, h 32768 -> row 360 = A2 110 Hz; hann overlap .75, 4 columns per bar
W=192
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
BAR="mod(floor(X/4),12)"
# roots: Am F Dm E | Am C G E | F Dm E A   as ratios to A
RT="if(eq(ld(0),1)+eq(ld(0),8),1.6,if(eq(ld(0),2)+eq(ld(0),9),1.33333333,if(eq(ld(0),3)+eq(ld(0),7)+eq(ld(0),10),1.5,if(eq(ld(0),5),1.2,if(eq(ld(0),6),1.8,1)))))"
# third: minor (6/5) on A and D, major (5/4) otherwise; final bar major
TH="if((eq(ld(0),0)+eq(ld(0),2)+eq(ld(0),4)+eq(ld(0),9)),1.2,1.25)"
# fold ratio r into window [L,2L): row = 360*r*2^ceil(log2(L/(360 r)))
FOLD="round(360*_R_*pow(2,ceil(log(_L_/(360*_R_))/log(2))))"
TONE="st(4,_ROW_);(eq(mod($K,ld(4)),0)*between($K,ld(4),4*ld(4))*pow($K/ld(4),-1.3))"
V="st(0,$BAR);st(1,$RT);st(2,$TH);(${TONE//_ROW_/${FOLD//_R_/ld(1)}})"
VB="${V//_L_/180}"; VT="${V//_L_/360}"; VT="${VT//ld(1)\*pow/ld(1)*1.5*pow}"
VT="st(0,$BAR);st(1,$RT);st(2,$TH);(${TONE//_ROW_/${FOLD//_R_/(ld(1)*1.5)}})"
VA="st(0,$BAR);st(1,$RT);st(2,$TH);(${TONE//_ROW_/${FOLD//_R_/(ld(1)*ld(2))}})"
VS="st(0,$BAR);st(1,$RT);st(2,$TH);(${TONE//_ROW_/${FOLD//_R_/(ld(1)*2)}})"
VB="${VB//_L_/180}"; VT="${VT//_L_/400}"; VA="${VA//_L_/540}"; VS="${VS//_L_/760}"
MAG="st(9,($VB)+0.8*($VT)+0.8*($VA)+0.9*($VS));if(gt(ld(9),0),255+2.125*(-16+8.6859*log(ld(9))),0)"
PHA="255*mod($K*X/4+mod(sin($K*12.9898+$LEFT*gt($K,400)*0.4)*43758.5453,1),1)"
SS="spectrumsynth=sample_rate=20025:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$MAG',format=yuvj444p,split=4[u0][u1][u2][u3];
[u0]crop=48:65536:0:0[v0];
[u1]crop=48:65536:48:0,split[t1][b1];[t1]crop=48:32768:0:0,uspp=quality=3:qp=8:codec=mjpeg[t1o];[b1]crop=48:32768:0:32768,uspp=quality=3:qp=8:codec=mjpeg[b1o];[t1o][b1o]vstack[v1];
[u2]crop=48:65536:96:0,split[t2][b2];[t2]crop=48:32768:0:0,uspp=quality=3:qp=18:codec=mjpeg[t2o];[b2]crop=48:32768:0:32768,uspp=quality=3:qp=18:codec=mjpeg[b2o];[t2o][b2o]vstack[v2];
[u3]crop=48:65536:144:0,split[t3][b3];[t3]crop=48:32768:0:0,uspp=quality=3:qp=31:codec=mjpeg[t3o];[b3]crop=48:32768:0:32768,uspp=quality=3:qp=31:codec=mjpeg[b3o];[t3o][b3o]vstack[v3];
[v0][v1][v2][v3]hstack=4,format=gray[m];
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$PHA'[p];
[m][p]$SS,aresample=48000,alimiter=limit=0.89:level=0" "$@"
