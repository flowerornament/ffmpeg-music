#!/bin/sh
# 207 — FRONT PAGE (overture: the record's README sings itself)
#
# studios/200/README.md is the front page of UNTRANSMITTED, and it is also this
# piece's score. Each line inside its box was counted to the byte: read by the DFPWM
# decoder at 96 kHz and held, a line of L bytes (newline included) sings 12000/L Hz,
# over the 12 kHz whine of the byte clock. Down the page the line lengths are
#   60 48 40 30 32 36 40 | 45 36 40 48 54 | 60 48 40 36 40 45 48 54 60
#   do mi sol do ti la sol  fa la sol mi re   do mi sol la sol fa mi re do
# and the two empty lines are rests. So the page you read before pressing play is a
# hymn tune, and its ragged right edge is the melody upside down.
# First time: the tune alone (27.00 s). Second time with a fifth and an octave below
# - the same held lines read at 64 and 48 kHz. Parallel organum works here, where it
# failed in 205, because here pitch is length, not history.
# The README is found from this file's own path: ${0%/pieces/*}/README.md.
ffmpeg -hide_banner -y \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,4,end,64,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,64,end,112,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,112,end,152,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,152,end,182,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,182,end,214,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,214,end,250,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,250,end,290,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,291,end,336,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,336,end,372,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,372,end,412,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,412,end,460,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,460,end,514,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,515,end,575,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,575,end,623,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,623,end,663,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,663,end,699,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,699,end,739,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,739,end,784,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,784,end,832,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,832,end,886,,:${0%/pieces/*}/README.md" \
 -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,886,end,946,,:${0%/pieces/*}/README.md" \
 -filter_complex "
 [0]atrim=start_sample=1440:end_sample=1920,asetpts=N/SR/TB,aloop=loop=-1:size=480,atrim=end_sample=960000,aformat=channel_layouts=mono,asplit=4[h0m1][h0m2][h0f2][h0o2];
 [h0m1]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s0m1];
 [h0m2]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s0m2];
 [h0f2]asetrate=64000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s0f2];
 [h0o2]asetrate=48000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s0o2];
 [1]atrim=start_sample=1152:end_sample=1536,asetpts=N/SR/TB,aloop=loop=-1:size=384,atrim=end_sample=768000,aformat=channel_layouts=mono,asplit=4[h1m1][h1m2][h1f2][h1o2];
 [h1m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s1m1];
 [h1m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s1m2];
 [h1f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s1f2];
 [h1o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s1o2];
 [2]atrim=start_sample=960:end_sample=1280,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=end_sample=640000,aformat=channel_layouts=mono,asplit=4[h2m1][h2m2][h2f2][h2o2];
 [h2m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s2m1];
 [h2m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s2m2];
 [h2f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s2f2];
 [h2o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s2o2];
 [3]atrim=start_sample=720:end_sample=960,asetpts=N/SR/TB,aloop=loop=-1:size=240,atrim=end_sample=480000,aformat=channel_layouts=mono,asplit=4[h3m1][h3m2][h3f2][h3o2];
 [h3m1]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s3m1];
 [h3m2]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s3m2];
 [h3f2]asetrate=64000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s3f2];
 [h3o2]asetrate=48000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s3o2];
 [4]atrim=start_sample=768:end_sample=1024,asetpts=N/SR/TB,aloop=loop=-1:size=256,atrim=end_sample=512000,aformat=channel_layouts=mono,asplit=4[h4m1][h4m2][h4f2][h4o2];
 [h4m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s4m1];
 [h4m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s4m2];
 [h4f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s4f2];
 [h4o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s4o2];
 [5]atrim=start_sample=864:end_sample=1152,asetpts=N/SR/TB,aloop=loop=-1:size=288,atrim=end_sample=576000,aformat=channel_layouts=mono,asplit=4[h5m1][h5m2][h5f2][h5o2];
 [h5m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s5m1];
 [h5m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s5m2];
 [h5f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s5f2];
 [h5o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s5o2];
 [6]atrim=start_sample=960:end_sample=1280,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=end_sample=640000,aformat=channel_layouts=mono,asplit=4[h6m1][h6m2][h6f2][h6o2];
 [h6m1]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s6m1];
 [h6m2]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s6m2];
 [h6f2]asetrate=64000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s6f2];
 [h6o2]asetrate=48000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s6o2];
 [7]atrim=start_sample=1080:end_sample=1440,asetpts=N/SR/TB,aloop=loop=-1:size=360,atrim=end_sample=720000,aformat=channel_layouts=mono,asplit=4[h7m1][h7m2][h7f2][h7o2];
 [h7m1]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s7m1];
 [h7m2]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s7m2];
 [h7f2]asetrate=64000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s7f2];
 [h7o2]asetrate=48000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s7o2];
 [8]atrim=start_sample=864:end_sample=1152,asetpts=N/SR/TB,aloop=loop=-1:size=288,atrim=end_sample=576000,aformat=channel_layouts=mono,asplit=4[h8m1][h8m2][h8f2][h8o2];
 [h8m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s8m1];
 [h8m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s8m2];
 [h8f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s8f2];
 [h8o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s8o2];
 [9]atrim=start_sample=960:end_sample=1280,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=end_sample=640000,aformat=channel_layouts=mono,asplit=4[h9m1][h9m2][h9f2][h9o2];
 [h9m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s9m1];
 [h9m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s9m2];
 [h9f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s9f2];
 [h9o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s9o2];
 [10]atrim=start_sample=1152:end_sample=1536,asetpts=N/SR/TB,aloop=loop=-1:size=384,atrim=end_sample=768000,aformat=channel_layouts=mono,asplit=4[h10m1][h10m2][h10f2][h10o2];
 [h10m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s10m1];
 [h10m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s10m2];
 [h10f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s10f2];
 [h10o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s10o2];
 [11]atrim=start_sample=1296:end_sample=1728,asetpts=N/SR/TB,aloop=loop=-1:size=432,atrim=end_sample=864000,aformat=channel_layouts=mono,asplit=4[h11m1][h11m2][h11f2][h11o2];
 [h11m1]aresample=48000,atrim=end=2.25,afade=t=in:d=0.03,afade=t=out:st=2.19:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s11m1];
 [h11m2]aresample=48000,atrim=end=2.25,afade=t=in:d=0.03,afade=t=out:st=2.19:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s11m2];
 [h11f2]asetrate=64000,aresample=48000,atrim=end=2.25,afade=t=in:d=0.03,afade=t=out:st=2.19:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s11f2];
 [h11o2]asetrate=48000,aresample=48000,atrim=end=2.25,afade=t=in:d=0.03,afade=t=out:st=2.19:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s11o2];
 [12]atrim=start_sample=1440:end_sample=1920,asetpts=N/SR/TB,aloop=loop=-1:size=480,atrim=end_sample=960000,aformat=channel_layouts=mono,asplit=4[h12m1][h12m2][h12f2][h12o2];
 [h12m1]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s12m1];
 [h12m2]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s12m2];
 [h12f2]asetrate=64000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s12f2];
 [h12o2]asetrate=48000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s12o2];
 [13]atrim=start_sample=1152:end_sample=1536,asetpts=N/SR/TB,aloop=loop=-1:size=384,atrim=end_sample=768000,aformat=channel_layouts=mono,asplit=4[h13m1][h13m2][h13f2][h13o2];
 [h13m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s13m1];
 [h13m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s13m2];
 [h13f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s13f2];
 [h13o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s13o2];
 [14]atrim=start_sample=960:end_sample=1280,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=end_sample=640000,aformat=channel_layouts=mono,asplit=4[h14m1][h14m2][h14f2][h14o2];
 [h14m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s14m1];
 [h14m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s14m2];
 [h14f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s14f2];
 [h14o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s14o2];
 [15]atrim=start_sample=864:end_sample=1152,asetpts=N/SR/TB,aloop=loop=-1:size=288,atrim=end_sample=576000,aformat=channel_layouts=mono,asplit=4[h15m1][h15m2][h15f2][h15o2];
 [h15m1]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s15m1];
 [h15m2]aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s15m2];
 [h15f2]asetrate=64000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s15f2];
 [h15o2]asetrate=48000,aresample=48000,atrim=end=1.5,afade=t=in:d=0.03,afade=t=out:st=1.44:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s15o2];
 [16]atrim=start_sample=960:end_sample=1280,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=end_sample=640000,aformat=channel_layouts=mono,asplit=4[h16m1][h16m2][h16f2][h16o2];
 [h16m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s16m1];
 [h16m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s16m2];
 [h16f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s16f2];
 [h16o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s16o2];
 [17]atrim=start_sample=1080:end_sample=1440,asetpts=N/SR/TB,aloop=loop=-1:size=360,atrim=end_sample=720000,aformat=channel_layouts=mono,asplit=4[h17m1][h17m2][h17f2][h17o2];
 [h17m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s17m1];
 [h17m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s17m2];
 [h17f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s17f2];
 [h17o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s17o2];
 [18]atrim=start_sample=1152:end_sample=1536,asetpts=N/SR/TB,aloop=loop=-1:size=384,atrim=end_sample=768000,aformat=channel_layouts=mono,asplit=4[h18m1][h18m2][h18f2][h18o2];
 [h18m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s18m1];
 [h18m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s18m2];
 [h18f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s18f2];
 [h18o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s18o2];
 [19]atrim=start_sample=1296:end_sample=1728,asetpts=N/SR/TB,aloop=loop=-1:size=432,atrim=end_sample=864000,aformat=channel_layouts=mono,asplit=4[h19m1][h19m2][h19f2][h19o2];
 [h19m1]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s19m1];
 [h19m2]aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s19m2];
 [h19f2]asetrate=64000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s19f2];
 [h19o2]asetrate=48000,aresample=48000,atrim=end=0.75,afade=t=in:d=0.03,afade=t=out:st=0.69:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s19o2];
 [20]atrim=start_sample=1440:end_sample=1920,asetpts=N/SR/TB,aloop=loop=-1:size=480,atrim=end_sample=960000,aformat=channel_layouts=mono,asplit=4[h20m1][h20m2][h20f2][h20o2];
 [h20m1]aresample=48000,atrim=end=4.5,afade=t=in:d=0.03,afade=t=out:st=4.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s20m1];
 [h20m2]aresample=48000,atrim=end=4.5,afade=t=in:d=0.03,afade=t=out:st=4.44:d=0.06,volume=1.0,aformat=sample_fmts=fltp:channel_layouts=mono[s20m2];
 [h20f2]asetrate=64000,aresample=48000,atrim=end=4.5,afade=t=in:d=0.03,afade=t=out:st=4.44:d=0.06,volume=0.7,aformat=sample_fmts=fltp:channel_layouts=mono[s20f2];
 [h20o2]asetrate=48000,aresample=48000,atrim=end=4.5,afade=t=in:d=0.03,afade=t=out:st=4.44:d=0.06,volume=0.8,aformat=sample_fmts=fltp:channel_layouts=mono[s20o2];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[rm17];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[rm113];
 [s0m1][s1m1][s2m1][s3m1][s4m1][s5m1][s6m1][rm17][s7m1][s8m1][s9m1][s10m1][s11m1][rm113][s12m1][s13m1][s14m1][s15m1][s16m1][s17m1][s18m1][s19m1][s20m1]concat=n=23:v=0:a=1[m1];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[rm27];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[rm213];
 [s0m2][s1m2][s2m2][s3m2][s4m2][s5m2][s6m2][rm27][s7m2][s8m2][s9m2][s10m2][s11m2][rm213][s12m2][s13m2][s14m2][s15m2][s16m2][s17m2][s18m2][s19m2][s20m2]concat=n=23:v=0:a=1[m2];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[rf27];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[rf213];
 [s0f2][s1f2][s2f2][s3f2][s4f2][s5f2][s6f2][rf27][s7f2][s8f2][s9f2][s10f2][s11f2][rf213][s12f2][s13f2][s14f2][s15f2][s16f2][s17f2][s18f2][s19f2][s20f2]concat=n=23:v=0:a=1[f2];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[ro27];
 anullsrc=r=48000:cl=mono:d=0.75,aformat=sample_fmts=fltp:channel_layouts=mono[ro213];
 [s0o2][s1o2][s2o2][s3o2][s4o2][s5o2][s6o2][ro27][s7o2][s8o2][s9o2][s10o2][s11o2][ro213][s12o2][s13o2][s14o2][s15o2][s16o2][s17o2][s18o2][s19o2][s20o2]concat=n=23:v=0:a=1[o2];
 anullsrc=r=48000:cl=mono:d=27.0,aformat=sample_fmts=fltp:channel_layouts=mono,asplit=2[z1][z2];
 [m1][m2]concat=n=2:v=0:a=1,pan=stereo|c0=0.8*c0|c1=0.8*c0[M];
 [z1][f2]concat=n=2:v=0:a=1,pan=stereo|c0=0.75*c0|c1=0.35*c0[F];
 [z2][o2]concat=n=2:v=0:a=1,pan=stereo|c0=0.35*c0|c1=0.75*c0[O];
 [M][F][O]amix=inputs=3:normalize=0,highpass=f=40,treble=g=-6:f=9000,aecho=0.8:0.5:211|337:0.25|0.18,apad=pad_dur=2,volume=1.3,alimiter=level=0:limit=0.8:attack=5:release=100[out]" -map "[out]" "$@"
