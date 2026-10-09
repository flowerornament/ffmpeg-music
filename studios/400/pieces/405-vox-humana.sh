#!/bin/sh
# 405 — Vox Humana  (Organology V)
#
# ffmpeg sings the first paragraph of its own manual through its own GSM 06.10 decoder:
#   "ffmpeg is a universal media converter. It can read a wide variety of inputs ...
#    and transcode them into a plethora of output formats."
# PIPES  Every sung note is one GSM full-rate frame (33 bytes, below as literal base64 in a
#        data: URI) decoded by libavcodec's gsm decoder; the steady third copy is looped.
#        A frame is a tiny vocal tract: 8 log-area ratios (designed from the formants of
#        e/i/a/u/o) and 4 sub-frames of RPE pulses: one glottal pulse every 40 samples
#        (S, A, T) or 80 (B). Pitch = the demuxer's declared sample_rate / 40 (or 80),
#        free like every pipe in this studio. The formants scale with the rate, so the
#        higher a voice sings the smaller its throat.
# UNDERTONE  The decoder's output repeats per 160-sample frame, never per sub-frame, so each
#        voice carries a growl two octaves below itself (kargyraa from a frame clock).
# SCORE  A aeolian with raised 7th, just intonation (E 3/2, F 8/5, D 4/3, C 6/5, G 9/5,
#        G# 15/8, B 9/8). Soprano lines written by hand, inner voices led by nearest motion.
#          I.   0:01 "ffmpeg is a universal media converter", soprano alone
#                    E E F | E D | C D E F | E D G# | A B A     (i i VI | III iv | VI VII III iv | i VII V | i V i)
#          II.  0:25 the same, four-part chorale
#          III. 0:52 "it can read a wide variety of inputs": the tenor takes the melody,
#                    rising to a half cadence on E
#          IV.  1:13 "and transcode them into a plethora of output formats": the soprano
#                    climbs to A5 on "ple-tho-ra" (abundance), then descends, broadening
#          V.   1:39 the last chord held while the vowel turns e -> a -> o
# ROOM   g723.1 cosine pedal on A1 (thinning while the tenor sings); reverb IR = libavcodec
#        machine code (the H.264 CABAC decoder and its neighbours), 3.5 s in each ear.
# The frames were packed by a helper (GSM bit layout, vowel LPC -> LARs); the strings are
# the score written in the decoder's own language.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
E40="1ahFo9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc1ahFo9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc1ahFo9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc"
E80="1ahFo9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj1ahFo9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj1ahFo9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj"
I40="1dwzr9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc1dwzr9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc1dwzr9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc"
I80="1dwzr9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj1dwzr9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj1dwzr9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj"
A40="0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0/hsl9pQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc"
A80="0/hsl9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj0/hsl9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj0/hsl9pQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj"
U40="0i6rVSdQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0i6rVSdQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0i6rVSdQB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc"
U80="0i6rVSdQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj0i6rVSdQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj0i6rVSdQB3ccccccUAA4444441AHdxxxxxxQADjjjjjj"
O40="0zPkVS9QB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0zPkVS9QB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc0zPkVS9QB3ccccccUAd3HHHHHFAHdxxxxxxQB3cccccc"
O80="0zPkVS9QB3ccccccUAA4444441AHdxxxxxxQADjjjjjj0zPkVS9QB3ccccccUAA4444441AHdxxxxxxQADjjjjjj0zPkVS9QB3ccccccUAA4444441AHdxxxxxxQADjjjjjj"
mov() { echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$4\\:ch_layout=mono'"; }
# sing FRAME RATE DELAY_MS LEN FADEOUT_AT GAIN LEFT RIGHT
sing() { echo "amovie='data\\:application/octet-stream;base64,$1':f=gsm:format_opts='sample_rate=$2',asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB,aresample=48000,atrim=0:$4,afade=t=in:d=0.06:curve=hsin,afade=t=out:st=$5:d=0.2:curve=hsin,volume=$6,pan=stereo|c0=$7*c0|c1=$8*c0,adelay=$3:all=1"; }
ffmpeg -hide_banner -y -filter_complex "
$(sing $E40 26400 1000 1.40 1.20 1.0 0.62 0.38)[v0];
$(sing $E40 26400 2150 1.40 1.20 1.0 0.62 0.38)[v1];
$(sing $E40 28160 3300 2.55 2.35 1.0 0.62 0.38)[v2];
$(sing $I40 26400 5600 1.40 1.20 1.0 0.62 0.38)[v3];
$(sing $A40 23467 6750 1.40 1.20 1.0 0.62 0.38)[v4];
$(sing $U40 21120 7900 1.40 1.20 1.0 0.62 0.38)[v5];
$(sing $I40 23467 9050 1.40 1.20 1.0 0.62 0.38)[v6];
$(sing $E40 26400 10200 1.40 1.20 1.0 0.62 0.38)[v7];
$(sing $A40 28160 11350 2.55 2.35 1.0 0.62 0.38)[v8];
$(sing $E40 26400 13650 1.40 1.20 1.0 0.62 0.38)[v9];
$(sing $I40 23467 14800 1.40 1.20 1.0 0.62 0.38)[v10];
$(sing $A40 16500 15950 2.55 2.35 1.0 0.62 0.38)[v11];
$(sing $O40 17600 18250 1.40 1.20 1.0 0.62 0.38)[v12];
$(sing $E40 19800 19400 1.40 1.20 1.0 0.62 0.38)[v13];
$(sing $E40 17600 20550 3.70 3.50 1.0 0.62 0.38)[v14];
$(sing $E40 26400 25500 1.55 1.35 0.8 0.62 0.38)[v15];
$(sing $E40 13200 25500 1.55 1.35 0.75 0.38 0.62)[v16];
$(sing $E40 10560 25500 1.55 1.35 0.8 0.56 0.44)[v17];
$(sing $E80 8800 25500 1.55 1.35 1.0 0.5 0.5)[v18];
$(sing $E40 26400 26800 1.55 1.35 0.8 0.62 0.38)[v19];
$(sing $E40 13200 26800 1.55 1.35 0.75 0.38 0.62)[v20];
$(sing $E40 10560 26800 1.55 1.35 0.8 0.56 0.44)[v21];
$(sing $E80 8800 26800 1.55 1.35 1.0 0.5 0.5)[v22];
$(sing $E40 28160 28100 2.85 2.65 0.8 0.62 0.38)[v23];
$(sing $E40 14080 28100 2.85 2.65 0.75 0.38 0.62)[v24];
$(sing $E40 10560 28100 2.85 2.65 0.8 0.56 0.44)[v25];
$(sing $E80 7040 28100 2.85 2.65 1.0 0.5 0.5)[v26];
$(sing $I40 26400 30700 1.55 1.35 0.8 0.62 0.38)[v27];
$(sing $I40 15840 30700 1.55 1.35 0.75 0.38 0.62)[v28];
$(sing $I40 10560 30700 1.55 1.35 0.8 0.56 0.44)[v29];
$(sing $I80 10560 30700 1.55 1.35 1.0 0.5 0.5)[v30];
$(sing $A40 23467 32000 1.55 1.35 0.8 0.62 0.38)[v31];
$(sing $A40 17600 32000 1.55 1.35 0.75 0.38 0.62)[v32];
$(sing $A40 11733 32000 1.55 1.35 0.8 0.56 0.44)[v33];
$(sing $A80 11733 32000 1.55 1.35 1.0 0.5 0.5)[v34];
$(sing $U40 21120 33300 1.55 1.35 0.8 0.62 0.38)[v35];
$(sing $U40 17600 33300 1.55 1.35 0.75 0.38 0.62)[v36];
$(sing $U40 10560 33300 1.55 1.35 0.8 0.56 0.44)[v37];
$(sing $U80 7040 33300 1.55 1.35 1.0 0.5 0.5)[v38];
$(sing $I40 23467 34599 1.55 1.35 0.8 0.62 0.38)[v39];
$(sing $I40 19800 34599 1.55 1.35 0.75 0.38 0.62)[v40];
$(sing $I40 9900 34599 1.55 1.35 0.8 0.56 0.44)[v41];
$(sing $I80 7920 34599 1.55 1.35 1.0 0.5 0.5)[v42];
$(sing $E40 26400 35899 1.55 1.35 0.8 0.62 0.38)[v43];
$(sing $E40 21120 35899 1.55 1.35 0.75 0.38 0.62)[v44];
$(sing $E40 10560 35899 1.55 1.35 0.8 0.56 0.44)[v45];
$(sing $E80 10560 35899 1.55 1.35 1.0 0.5 0.5)[v46];
$(sing $A40 28160 37199 2.85 2.65 0.8 0.62 0.38)[v47];
$(sing $A40 17600 37199 2.85 2.65 0.75 0.38 0.62)[v48];
$(sing $A40 11733 37199 2.85 2.65 0.8 0.56 0.44)[v49];
$(sing $A80 11733 37199 2.85 2.65 1.0 0.5 0.5)[v50];
$(sing $E40 26400 39799 1.55 1.35 0.8 0.62 0.38)[v51];
$(sing $E40 17600 39799 1.55 1.35 0.75 0.38 0.62)[v52];
$(sing $E40 10560 39799 1.55 1.35 0.8 0.56 0.44)[v53];
$(sing $E80 8800 39799 1.55 1.35 1.0 0.5 0.5)[v54];
$(sing $I40 23467 41099 1.55 1.35 0.8 0.62 0.38)[v55];
$(sing $I40 19800 41099 1.55 1.35 0.75 0.38 0.62)[v56];
$(sing $I40 9900 41099 1.55 1.35 0.8 0.56 0.44)[v57];
$(sing $I80 7920 41099 1.55 1.35 1.0 0.5 0.5)[v58];
$(sing $A40 16500 42399 2.85 2.65 0.8 0.62 0.38)[v59];
$(sing $A40 13200 42399 2.85 2.65 0.75 0.38 0.62)[v60];
$(sing $A40 9900 42399 2.85 2.65 0.8 0.56 0.44)[v61];
$(sing $A80 6600 42399 2.85 2.65 1.0 0.5 0.5)[v62];
$(sing $O40 17600 44999 1.55 1.35 0.8 0.62 0.38)[v63];
$(sing $O40 13200 44999 1.55 1.35 0.75 0.38 0.62)[v64];
$(sing $O40 10560 44999 1.55 1.35 0.8 0.56 0.44)[v65];
$(sing $O80 8800 44999 1.55 1.35 1.0 0.5 0.5)[v66];
$(sing $E40 19800 46299 1.55 1.35 0.8 0.62 0.38)[v67];
$(sing $E40 13200 46299 1.55 1.35 0.75 0.38 0.62)[v68];
$(sing $E40 9900 46299 1.55 1.35 0.8 0.56 0.44)[v69];
$(sing $E80 6600 46299 1.55 1.35 1.0 0.5 0.5)[v70];
$(sing $E40 17600 47599 4.15 3.95 0.8 0.62 0.38)[v71];
$(sing $E40 13200 47599 4.15 3.95 0.75 0.38 0.62)[v72];
$(sing $E40 10560 47599 4.15 3.95 0.8 0.56 0.44)[v73];
$(sing $E80 8800 47599 4.15 3.95 1.0 0.5 0.5)[v74];
$(sing $I40 10560 51899 1.55 1.35 0.95 0.56 0.44)[v75];
$(sing $I40 14080 51899 1.55 1.35 0.6 0.38 0.62)[v76];
$(sing $I80 7040 51899 1.55 1.35 0.9 0.5 0.5)[v77];
$(sing $A40 11733 53199 1.55 1.35 0.95 0.56 0.44)[v78];
$(sing $A40 15840 53199 1.55 1.35 0.6 0.38 0.62)[v79];
$(sing $A80 7920 53199 1.55 1.35 0.9 0.5 0.5)[v80];
$(sing $I40 13200 54499 2.85 2.65 0.95 0.56 0.44)[v81];
$(sing $I40 17600 54499 2.85 2.65 0.6 0.38 0.62)[v82];
$(sing $I80 8800 54499 2.85 2.65 0.9 0.5 0.5)[v83];
$(sing $A40 13200 57099 1.55 1.35 0.95 0.56 0.44)[v84];
$(sing $A40 15840 57099 1.55 1.35 0.6 0.38 0.62)[v85];
$(sing $A80 10560 57099 1.55 1.35 0.9 0.5 0.5)[v86];
$(sing $A40 14080 58399 2.85 2.65 0.95 0.56 0.44)[v87];
$(sing $A40 17600 58399 2.85 2.65 0.6 0.38 0.62)[v88];
$(sing $A80 11733 58399 2.85 2.65 0.9 0.5 0.5)[v89];
$(sing $A40 13200 60999 1.55 1.35 0.95 0.56 0.44)[v90];
$(sing $A40 17600 60999 1.55 1.35 0.6 0.38 0.62)[v91];
$(sing $A80 8800 60999 1.55 1.35 0.9 0.5 0.5)[v92];
$(sing $I40 11733 62299 1.55 1.35 0.95 0.56 0.44)[v93];
$(sing $I40 19800 62299 1.55 1.35 0.6 0.38 0.62)[v94];
$(sing $I80 7920 62299 1.55 1.35 0.9 0.5 0.5)[v95];
$(sing $E40 10560 63599 1.55 1.35 0.95 0.56 0.44)[v96];
$(sing $E40 17600 63599 1.55 1.35 0.6 0.38 0.62)[v97];
$(sing $E80 7040 63599 1.55 1.35 0.9 0.5 0.5)[v98];
$(sing $I40 9900 64899 1.55 1.35 0.95 0.56 0.44)[v99];
$(sing $I40 16500 64899 1.55 1.35 0.6 0.38 0.62)[v100];
$(sing $I80 6600 64899 1.55 1.35 0.9 0.5 0.5)[v101];
$(sing $O40 10560 66199 1.55 1.35 0.95 0.56 0.44)[v102];
$(sing $O40 17600 66199 1.55 1.35 0.6 0.38 0.62)[v103];
$(sing $O80 7040 66199 1.55 1.35 0.9 0.5 0.5)[v104];
$(sing $I40 11733 67499 1.55 1.35 0.95 0.56 0.44)[v105];
$(sing $I40 17600 67499 1.55 1.35 0.6 0.38 0.62)[v106];
$(sing $I80 5867 67499 1.55 1.35 0.9 0.5 0.5)[v107];
$(sing $U40 13200 68799 4.15 3.95 0.95 0.56 0.44)[v108];
$(sing $U40 16500 68799 4.15 3.95 0.6 0.38 0.62)[v109];
$(sing $U80 6600 68799 4.15 3.95 0.9 0.5 0.5)[v110];
$(sing $A40 26400 73099 1.55 1.35 0.8 0.62 0.38)[v111];
$(sing $A40 17600 73099 1.55 1.35 0.75 0.38 0.62)[v112];
$(sing $A40 10560 73099 1.55 1.35 0.8 0.56 0.44)[v113];
$(sing $A80 8800 73099 1.55 1.35 1.0 0.5 0.5)[v114];
$(sing $A40 28160 74399 1.55 1.35 0.8 0.62 0.38)[v115];
$(sing $A40 17600 74399 1.55 1.35 0.75 0.38 0.62)[v116];
$(sing $A40 10560 74399 1.55 1.35 0.8 0.56 0.44)[v117];
$(sing $A80 7040 74399 1.55 1.35 1.0 0.5 0.5)[v118];
$(sing $O40 31680 75699 2.85 2.65 0.8 0.62 0.38)[v119];
$(sing $O40 19800 75699 2.85 2.65 0.75 0.38 0.62)[v120];
$(sing $O40 11733 75699 2.85 2.65 0.8 0.56 0.44)[v121];
$(sing $O80 7920 75699 2.85 2.65 1.0 0.5 0.5)[v122];
$(sing $E40 35200 78299 1.55 1.35 0.8 0.62 0.38)[v123];
$(sing $E40 17600 78299 1.55 1.35 0.75 0.38 0.62)[v124];
$(sing $E40 11733 78299 1.55 1.35 0.8 0.56 0.44)[v125];
$(sing $E80 5867 78299 1.55 1.35 1.0 0.5 0.5)[v126];
$(sing $I40 31680 79599 1.55 1.35 0.8 0.62 0.38)[v127];
$(sing $I40 15840 79599 1.55 1.35 0.75 0.38 0.62)[v128];
$(sing $I40 13200 79599 1.55 1.35 0.8 0.56 0.44)[v129];
$(sing $I80 10560 79599 1.55 1.35 1.0 0.5 0.5)[v130];
$(sing $U40 28160 80899 1.55 1.35 0.8 0.62 0.38)[v131];
$(sing $U40 17600 80899 1.55 1.35 0.75 0.38 0.62)[v132];
$(sing $U40 14080 80899 1.55 1.35 0.8 0.56 0.44)[v133];
$(sing $U80 7040 80899 1.55 1.35 1.0 0.5 0.5)[v134];
$(sing $A40 26400 82199 1.55 1.35 0.8 0.62 0.38)[v135];
$(sing $A40 17600 82199 1.55 1.35 0.75 0.38 0.62)[v136];
$(sing $A40 13200 82199 1.55 1.35 0.8 0.56 0.44)[v137];
$(sing $A80 8800 82199 1.55 1.35 1.0 0.5 0.5)[v138];
$(sing $E40 35200 83499 2.85 2.65 0.8 0.62 0.38)[v139];
$(sing $E40 17600 83499 2.85 2.65 0.75 0.38 0.62)[v140];
$(sing $E40 14080 83499 2.85 2.65 0.8 0.56 0.44)[v141];
$(sing $E80 11733 83499 2.85 2.65 1.0 0.5 0.5)[v142];
$(sing $O40 33000 86099 1.55 1.35 0.8 0.62 0.38)[v143];
$(sing $O40 19800 86099 1.55 1.35 0.75 0.38 0.62)[v144];
$(sing $O40 13200 86099 1.55 1.35 0.8 0.56 0.44)[v145];
$(sing $O80 13200 86099 1.55 1.35 1.0 0.5 0.5)[v146];
$(sing $A40 35200 87399 1.55 1.35 0.8 0.62 0.38)[v147];
$(sing $A40 21120 87399 1.55 1.35 0.75 0.38 0.62)[v148];
$(sing $A40 13200 87399 1.55 1.35 0.8 0.56 0.44)[v149];
$(sing $A80 8800 87399 1.55 1.35 1.0 0.5 0.5)[v150];
$(sing $O40 26400 88699 1.55 1.35 0.8 0.62 0.38)[v151];
$(sing $O40 21120 88699 1.55 1.35 0.75 0.38 0.62)[v152];
$(sing $O40 13200 88699 1.55 1.35 0.8 0.56 0.44)[v153];
$(sing $O80 8800 88699 1.55 1.35 1.0 0.5 0.5)[v154];
$(sing $O40 23467 89999 2.07 1.87 0.8 0.62 0.38)[v155];
$(sing $O40 17600 89999 2.07 1.87 0.75 0.38 0.62)[v156];
$(sing $O40 14080 89999 2.07 1.87 0.8 0.56 0.44)[v157];
$(sing $O80 11733 89999 2.07 1.87 1.0 0.5 0.5)[v158];
$(sing $U40 21120 91819 2.07 1.87 0.8 0.62 0.38)[v159];
$(sing $U40 17600 91819 2.07 1.87 0.75 0.38 0.62)[v160];
$(sing $U40 14080 91819 2.07 1.87 0.8 0.56 0.44)[v161];
$(sing $U80 7040 91819 2.07 1.87 1.0 0.5 0.5)[v162];
$(sing $O40 19800 93639 2.07 1.87 0.8 0.62 0.38)[v163];
$(sing $O40 16500 93639 2.07 1.87 0.75 0.38 0.62)[v164];
$(sing $O40 13200 93639 2.07 1.87 0.8 0.56 0.44)[v165];
$(sing $O80 6600 93639 2.07 1.87 1.0 0.5 0.5)[v166];
$(sing $A40 17600 95459 7.53 7.33 0.8 0.62 0.38)[v167];
$(sing $A40 13200 95459 7.53 7.33 0.75 0.38 0.62)[v168];
$(sing $A40 10560 95459 7.53 7.33 0.8 0.56 0.44)[v169];
$(sing $A80 8800 95459 7.53 7.33 1.0 0.5 0.5)[v170];
$(sing $E40 17600 99099 8.25 8.05 0.8 0.62 0.38)[v171];
$(sing $E40 13200 99099 8.25 8.05 0.75 0.38 0.62)[v172];
$(sing $E40 10560 99099 8.25 8.05 0.8 0.56 0.44)[v173];
$(sing $E80 8800 99099 8.25 8.05 1.0 0.5 0.5)[v174];
$(sing $A40 17600 104099 8.25 8.05 0.8 0.62 0.38)[v175];
$(sing $A40 13200 104099 8.25 8.05 0.75 0.38 0.62)[v176];
$(sing $A40 10560 104099 8.25 8.05 0.8 0.56 0.44)[v177];
$(sing $A80 8800 104099 8.25 8.05 1.0 0.5 0.5)[v178];
$(sing $O40 17600 109099 8.25 8.05 0.8 0.62 0.38)[v179];
$(sing $O40 13200 109099 8.25 8.05 0.75 0.38 0.62)[v180];
$(sing $O40 10560 109099 8.25 8.05 0.8 0.56 0.44)[v181];
$(sing $O80 8800 109099 8.25 8.05 1.0 0.5 0.5)[v182];
[v0][v1][v2][v3][v4][v5][v6][v7][v8][v9][v10][v11][v12][v13][v14][v15][v16][v17][v18][v19][v20][v21][v22][v23][v24][v25][v26][v27][v28][v29][v30][v31][v32][v33][v34][v35][v36][v37][v38][v39][v40][v41][v42][v43][v44][v45][v46][v47][v48][v49][v50][v51][v52][v53][v54][v55][v56][v57][v58][v59][v60][v61][v62][v63][v64][v65][v66][v67][v68][v69][v70][v71][v72][v73][v74][v75][v76][v77][v78][v79][v80][v81][v82][v83][v84][v85][v86][v87][v88][v89][v90][v91][v92][v93][v94][v95][v96][v97][v98][v99][v100][v101][v102][v103][v104][v105][v106][v107][v108][v109][v110][v111][v112][v113][v114][v115][v116][v117][v118][v119][v120][v121][v122][v123][v124][v125][v126][v127][v128][v129][v130][v131][v132][v133][v134][v135][v136][v137][v138][v139][v140][v141][v142][v143][v144][v145][v146][v147][v148][v149][v150][v151][v152][v153][v154][v155][v156][v157][v158][v159][v160][v161][v162][v163][v164][v165][v166][v167][v168][v169][v170][v171][v172][v173][v174][v175][v176][v177][v178][v179][v180][v181][v182]amix=inputs=183:normalize=0:duration=longest,highpass=f=60,lowpass=f=10000,chorus=in_gain=0.7:out_gain=0.9:delays='43|61':decays='0.3|0.25':speeds='0.3|0.21':depths='1.5|1.9',asplit[dry][w0];
$(mov 0xcc09f0 1024 s16le 28160),aloop=-1:512,aresample=48000,atrim=0:95,afade=t=in:d=4,afade=t=out:st=82:d=13,
 volume='0.06*(1-0.8*min(1,max(0,min((t-25)/3,(47-t)/3))))':eval=frame,adelay=25000:all=1,pan=stereo|c0=c0|c1=c0[pedal];
$(mov 0x2f42c4 168000 u8 48000),highpass=f=200,lowpass=f=4500,afade=t=out:st=0:d=3.5:curve=exp[irL];
$(mov 0x3a42c4 168000 u8 48000),highpass=f=200,lowpass=f=4500,afade=t=out:st=0:d=3.5:curve=exp[irR];
[irL][irR]amerge[ir];[w0][ir]afir=irnorm=2,volume=0.35[wet];
[dry][wet][pedal]amix=inputs=3:normalize=0,volume=3.0,acompressor=threshold=0.3:ratio=2:attack=10:release=200,
 alimiter=limit=0.8:level=0,atrim=0:121,afade=t=out:st=116:d=5
" "$@"
