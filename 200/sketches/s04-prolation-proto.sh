#!/bin/sh
# lezehazthe tc hroatc  is amm f
# lezehatilterc  madec  of lmmet
# wcrkeazters.c  i brc eathem  i
# lezehatn twec nty mc illismmec
# lezehezonds e and sg peak mmin
# lezehet frame es. eg very mmli
# ocnpwezne a e breatgmh, evm er
# lezehyty letyzter ayz musca le
# s04: the stanza above (bytes 12..276) read by GSM at 8 speeds: 4:5:6:8 low (rhythm) and x64 (tone)
ffmpeg -hide_banner -y \
 -stream_loop -1 -f gsm -sample_rate 400 -i "subfile,,start,12,end,276,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 500 -i "subfile,,start,12,end,276,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 600 -i "subfile,,start,12,end,276,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 800 -i "subfile,,start,12,end,276,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 25600 -i "subfile,,start,12,end,276,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 32000 -i "subfile,,start,12,end,276,,:$0" \
 -filter_complex "[0]aresample=48000[a];[1]aresample=48000[b];[2]aresample=48000[c];[3]aresample=48000[d];[4]aresample=48000,volume=0.3[e];[5]aresample=48000,volume=0.3[f];
 [a][b][c][d][e][f]amix=inputs=6:normalize=0,highpass=f=25,atrim=0:30,alimiter" "$@"
