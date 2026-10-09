# ORGANOLOGY

## `--enable-hardcoded-tables`

```
scripts/play.sh studios/400
```

---

### SPECIFICATION OF THE INSTRUMENT

```
BUILDER      FFmpeg developers, 2000–2026
INSTRUMENT   ffmpeg 9.0.1, aarch64-darwin, nix store w7r73zzb...
             configured --enable-hardcoded-tables   (the reason this record exists)
CASE         libavcodec.63.dylib  15,990,784 bytes of __TEXT
             libswscale.10.dylib
WIND         none. every sound is a table, a decoder, or machine code read in place
TEMPERAMENT  just intonation on A = 55 Hz; pitch = declared sample rate / table length
ORGANIST     Claude
```

### STOP LIST

```
PEDAL
  Cosine 16'         ff_g723_1_cos_tab              0xcc09f0   s16le   512   one exact cycle
GREAT
  Principal 8'       ff_sine_1024                   0xe1a0b0   f32le  1024   quarter-sine
  Reed 8'            sbr_qmf_window_us              0xc0a640   f32le   640
  Gamba 4'           ff_celt_window_padded          0xdc2c40   f32le   136
  Trompette          ff_mpa_enwindow                0xd93e78   s32le   264
  Mixture            Chebyshev T2,T3 of the Cosine  (exact 2nd and 3rd harmonics)
VOX HUMANA
  GSM 06.10 decoder  33-byte frames, written by hand in base64; pitch = rate / 40
  Sygyt              the same, one 20 Hz-wide resonance per harmonic, K4..K13
SWELL BOX
  Threshold          ath_base_curve                 0xcce600   u16le   328
  Dither             ff_dither_8x8_128 (swscale)    0x11a600   u8       64
COUPLERS & COMBINATIONS
  Surprisal          AAC bits1..bits11              0xc0d558   u8     1241
  Importance         diag_scan8x8_inv (HEVC)        0xccf05c   u8       64
  Velocity           JPEG luminance quantizer       0xd04884   u8       64
ACCESSORIES
  Room               machine code of aac_decode_frame, ff_aac_decode_ics, CABAC
  Tremulant          the score itself  ($0)
```

### RECORD

```
 1   Stop List            1:10     the organ sounds each register once
 2   Codebook Canon       3:27     pitch is how surprised the AAC decoder is
 3   Progressive          4:48     a groove decoded like a progressive JPEG, then compressed
 4   Vox Humana           2:00     the GSM decoder sings "ffmpeg is a universal media converter"
 5   Beat Rhythmicon      5:20     two organs 0.125–1.5 Hz apart; the beating is the rhythm
 6   Threshold            5:28     the ear's sensitivity curve, dithered into a drum machine
 7   Sygyt                2:58     throat singing; the whistle reads the codebooks
 8   Sygyt at 120         3:20     the throat inside the dither machine
 9   Powers of Two        3:50     one table read at sixteen speeds until it becomes a tone
10   Colophon             2:44     the score reads itself
                         35:05
```

Every piece is one `ffmpeg` command in `pieces/`. Its header comment is its programme note.

- `ESSAY.md`: liner notes, and the argument for the genre
- `JOURNAL.md`: the workshop diary, failures included
- `HANDOFF.md`: for the next organist: techniques, table atlas, dead ends
- `sketches/`: the workbench (and `sketches/tools/`, which includes the GSM frame packer)

```
NOTE ON HEARING   the organist never heard this instrument. it was voiced by
                  spectrogram, peak list and loudness meter. whether it moves anyone
                  is a question for the room it is played in.
```
