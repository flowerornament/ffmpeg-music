# A house loop painted as one image, heard two ways (geometry G12, see s04).
# S(c,k): c = column (time, 0..191), k = row from bottom (0..191). Partial p = k/6 <-> step p.
#  kick partials p%4==0 lit only at the frame start (decay)   -> in B: low thumps on the beat
#  hat partials  p%4==2 swelling toward the frame end         -> in B: bright offbeat ticks
#  chord partials (mask per frame) sustained                   -> in B: full-band ticks = claps
# B = S transposed (time<->freq), stretched to 513 bins, rotated by 4 steps so p=4 is the one.
CH="if(eq(mod(N,2),0),$((1<<5|1<<7|1<<10|1<<15|1<<20)),$((1<<5|1<<9|1<<11|1<<15|1<<18|1<<22)))"
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=192x192:r=12000/49152:d=17,format=gray16,geq=lum='st(0,191-Y);st(1,floor(ld(0)/6));
 eq(mod(ld(0),6),0)*gte(ld(1),1)*(
  12000*eq(mod(ld(1),4),0)*exp(-X/4)
 +3000*eq(mod(ld(1),4),2)*pow(X/191,6)
 +1500*mod(floor($CH/pow(2,ld(1))),2))',split[s1][s2];
[s1]pad=192:513:0:321[a];
[s2]transpose=clock_flip,scale=192x513:flags=neighbor,split[b1][b2];
[b1]crop=168:513:24:0[bl];[b2]crop=24:513:0:0[br];[bl][br]hstack[b];
nullsrc=s=192x513:r=12000/49152:d=17,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4,1)',split[pa][pb];
[a][pa]spectrumsynth=sample_rate=12000:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[A];
[b][pb]spectrumsynth=sample_rate=12000:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[B];
[A][B]amerge,aresample=48000" "$@"
