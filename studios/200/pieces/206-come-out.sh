#!/bin/sh
# hahoffwardclackertrucialsquali
# hahsquirtysquinchupsurgeaphoni
# hahpoutfulgonapodunstickanoesi
# hahamotionalmoignclypeusskippe
# hahajivikakineticmixablechatte
# hahoghamicaflightbebarongenito
# hahidiotcyecotypeabigeatmagica
# paldepaintajanglecoronetunshap
# palunshadyimpubicamnesicalquie
# palakepiroajangleajivikasinuos
# palchoregyagentryafflictkeyhol
# paladzooksacrylicebonizetashri
# bib  sleep  waits  sleep  stil
# hah  river  night  still  slee
# bibaffixeremirateaseethefrigat
# bibermelinprosectsqueezyaquabi
# bibsquelchspitfulaposoroloafle
# bibmonikeronwardsungrandemulso
# bibblaubokfleetlyskippertjosit
# bibajivikabiotomychutneyagalit
# bibagonizeeffulgebechaseudalle
# bibscummedscaffieabridgelauron
# impsemballtitrateamandinomalgi
# impalfonsoplaculaskeggersjambo
# impdisjoincheerlyagistoroffens
# impmetheneodonticoceanedpassad
# hah  still  river  quiet  wait
# peaeffendisketchyaquaticsquare
# peaapsidesoptimumspittedupspea
# peayouwardmooneyecottagesnozzl
# peaknackersmokingamidasecleruc
# peaoldsterskiddedskiapodajivik
# peaajanglepimperydilluerwheele
# peathurmusagnosiaegotismafflic
# peabehenicbesmearodorousscabbe
# peaaccingeabjointwaxbushsalite
# hahmetayerejectorpotableunstoi
# hahuncubicamoraimambriteslocke
# hahskylookajangleijolitehiatio
# hahchooseragavoseoffscumdecret
# hahidioticacidizeabietinmasoni
# hah  sleep  river  still  nigh
# bib  still  quiet  sleep  quie
# hah  still  waits  waits  nigh
# hah  night  night  still  stil
# bib  river  still  quiet  slee
# hah  night  sleep  river  stil
# hah  quiet  quiet  quiet  nigh
#
# 206 — COME OUT (for two telephones and then eight)
#
# The 48 lines above are one spoken phrase: GSM frames (see 201) whose loudness
# letters were set syllable by syllable - attack, sustain, decay, a gap - with words
# drawn from the dictionary by their second letter (sketches/tools/gsmverse.py,
# seed 5). Read at 6000 Hz the phrase lasts 1.28 s: six "syllables" of a voice that
# is only a model of a throat, saying a sentence nobody wrote.
#
# Then Steve Reich's process from "Come Out" (1966), done with sample rates instead
# of tape machines. Two decoders read the phrase on a loop, left at 6000 Hz, right at
# 6003: the right one gains half a millisecond a second, so the voices fuse, then
# flange, then echo, then fall into a canon. At 2:24 two more readers enter at 6006
# and 6009; at 3:12 four more at 6012..6021, and the phrase becomes a crowd that is
# still one sentence. Every reading is upsampled with a 1-tap resampler, so each
# rate leaves its own images above 3 kHz: the crowd's air is made of its sample rates.
ffmpeg -hide_banner -y \
 -stream_loop -1 -f gsm -sample_rate 6000 -i "subfile,,start,10,end,1594,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 6003 -i "subfile,,start,10,end,1594,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 6006 -i "subfile,,start,10,end,1594,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 6009 -i "subfile,,start,10,end,1594,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 6012 -i "subfile,,start,10,end,1594,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 6015 -i "subfile,,start,10,end,1594,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 6018 -i "subfile,,start,10,end,1594,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 6021 -i "subfile,,start,10,end,1594,,:$0" \
 -filter_complex "
 [0]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume=0.75,pan=stereo|c0=c0|c1=0.12*c0[v0];
 [1]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume=0.75,pan=stereo|c0=0.12*c0|c1=c0[v1];
 [2]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume='0.5*clip((t-144)/6,0,1)':eval=frame,pan=stereo|c0=0.8*c0|c1=0.45*c0[v2];
 [3]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume='0.5*clip((t-144)/6,0,1)':eval=frame,pan=stereo|c0=0.45*c0|c1=0.8*c0[v3];
 [4]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume='0.35*clip((t-192)/8,0,1)':eval=frame,pan=stereo|c0=c0|c1=0.6*c0[v4];
 [5]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume='0.35*clip((t-192)/8,0,1)':eval=frame,pan=stereo|c0=0.6*c0|c1=c0[v5];
 [6]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume='0.35*clip((t-192)/8,0,1)':eval=frame,pan=stereo|c0=0.9*c0|c1=0.3*c0[v6];
 [7]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,volume='0.35*clip((t-192)/8,0,1)':eval=frame,pan=stereo|c0=0.3*c0|c1=0.9*c0[v7];
 [v0][v1][v2][v3][v4][v5][v6][v7]amix=inputs=8:normalize=0,highpass=f=35,volume=1.55,alimiter=level=0:limit=0.8:attack=3:release=80,afade=t=in:d=0.05,afade=t=out:st=262:d=8
 " -t 270 "$@"
