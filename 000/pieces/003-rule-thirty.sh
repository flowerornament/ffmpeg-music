#!/bin/sh
# 003 — Rule Thirty (scratch sketch A, kept because the listener liked it)
# Wolfram's rule-30 automaton scrolls through the inverse FFT as a magnitude spectrum,
# a zone plate supplies the phase. The universe's simplest chaos, heard as a 513-bin spectrum.
ffmpeg -hide_banner -y -filter_complex "cellauto=rule=30:s=1024x513:r=187.5:scroll=1,format=gray,trim=duration=30[m];zoneplate=s=1024x513:r=187.5,format=gray,trim=duration=30[p];[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,volume=0.3,alimiter" "$@"
