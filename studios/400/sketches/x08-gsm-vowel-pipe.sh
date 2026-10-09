#!/bin/sh
# x08 — one GSM vowel pipe (the atom of 405/408/409). An 'a' frame (tools/gsmframes.py vowel a 40),
# decoded at declared rates 8800, 13200, 17600 -> 220, 330, 440 Hz: an A major-ish triad,
# formants scaling with pitch. Note the asetpts dance: without it the render hangs.
ffmpeg -hide_banner -y -filter_complex "
amovie='data\:application/octet-stream;base64,0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc':f=gsm:format_opts='sample_rate=8800',asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB,aresample=48000,atrim=0:4[a];
amovie='data\:application/octet-stream;base64,0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc':f=gsm:format_opts='sample_rate=13200',asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB,aresample=48000,atrim=0:4[b];
amovie='data\:application/octet-stream;base64,0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc':f=gsm:format_opts='sample_rate=17600',asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB,aresample=48000,atrim=0:4[c];
[a][b][c]amix=inputs=3,volume=2" "$@"
