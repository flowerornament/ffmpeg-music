Apply an arbitrary Finite Impulse Response filter.

This filter is designed for applying long FIR filters, up to 60 seconds long.

It can be used as component for digital crossover filters, room equalization, cross talk cancellation, wavefield synthesis, auralization, ambiophonics, ambisonics and spatialization.

This filter uses the streams higher than first one as FIR coefficients. If the non-first stream holds a single channel, it will be used for all input channels in the first stream, otherwise the number of channels in the non-first stream must be same as the number of channels in the first stream.

It accepts the following parameters:

`dry`  
Set dry gain. This sets input gain.

`wet`  
Set wet gain. This sets final output gain.

`length`  
Set Impulse Response filter length. Default is 1, which means whole IR is processed.

`gtype`  
This option is deprecated, and does nothing.

`irnorm`  
Set norm to be applied to IR coefficients before filtering. Allowed range is from `-1` to `2`. IR coefficients are normalized with calculated vector norm set by this option. For negative values, no norm is calculated, and IR coefficients are not modified at all. Default is `1`.

`irlink`  
For multichannel IR if this option is set to `true`, all IR channels will be normalized with maximal measured gain of all IR channels coefficients as set by `irnorm` option. When disabled, all IR coefficients in each IR channel will be normalized independently. Default is `true`.

`irgain`  
Set gain to be applied to IR coefficients before filtering. Allowed range is 0 to 1. This gain is applied after any gain applied with `irnorm` option.

`irfmt`  
Set format of IR stream. Can be `mono` or `input`. Default is `input`.

`maxir`  
Set max allowed Impulse Response filter duration in seconds. Default is 30 seconds. Allowed range is 0.1 to 60 seconds.

`response`  
This option is deprecated, and does nothing.

`channel`  
This option is deprecated, and does nothing.

`size`  
This option is deprecated, and does nothing.

`rate`  
This option is deprecated, and does nothing.

`minp`  
Set minimal partition size used for convolution. Default is `8192`. Allowed range is from `1` to `65536`. Lower values decreases latency at cost of higher CPU usage.

`maxp`  
Set maximal partition size used for convolution. Default is `8192`. Allowed range is from `8` to `65536`. Lower values may increase CPU usage.

`nbirs`  
Set number of input impulse responses streams which will be switchable at runtime. Allowed range is from `1` to `32`. Default is `1`.

`ir`  
Set IR stream which will be used for convolution, starting from `0`, should always be lower than supplied value by `nbirs` option. Default is `0`. This option can be changed at runtime via [commands](#commands).

`precision`  
Set which precision to use when processing samples.

`auto`  
Auto pick internal sample format depending on other filters.

`float`  
Always use single-floating point precision sample format.

`double`  
Always use double-floating point precision sample format.

Default value is auto.

`irload`  
Set when to load IR stream. Can be `init` or `access`. First one load and prepares all IRs on initialization, second one once on first access of specific IR. Default is `init`.

#### 8.25.1 Examples[\#](#Examples-9) [TOC](#toc-Examples-9)

- Apply reverb to stream using mono IR file as second input, complete command using ffmpeg:
  ``` example-preformatted
  ffmpeg -i input.wav -i middle_tunnel_1way_mono.wav -lavfi afir output.wav
  ```
- Apply true stereo processing given input stereo stream, and two stereo impulse responses for left and right channel, the impulse response files are files with names l_ir.wav and r_ir.wav, and setting irnorm option value:
  ``` example-preformatted
  "pan=4C|c0=FL|c1=FL|c2=FR|c3=FR[a];amovie=l_ir.wav[LIR];amovie=r_ir.wav[RIR];[LIR][RIR]amerge[ir];[a][ir]afir=irfmt=input:irnorm=1.2,pan=stereo|FL<c0+c2|FR<c1+c3"
  ```
- Similar to above example, but with `irgain` explicitly set to estimated value and with `irnorm` disabled:
  ``` example-preformatted
  "pan=4C|c0=FL|c1=FL|c2=FR|c3=FR[a];amovie=l_ir.wav[LIR];amovie=r_ir.wav[RIR];[LIR][RIR]amerge[ir];[a][ir]afir=irfmt=input:irgain=-5dB:irnom=-1,pan=stereo|FL<c0+c2|FR<c1+c3"
  ```

### 8.26 aformat[\#](#aformat-1) [TOC](#toc-aformat-1)

Set output format constraints for the input audio. The framework will negotiate the most appropriate format to minimize conversions.

It accepts the following parameters:

`sample_fmts, f`  
A ’\|’-separated list of requested sample formats.

`sample_rates, r`  
A ’\|’-separated list of requested sample rates.

`channel_layouts, cl`  
A ’\|’-separated list of requested channel layouts.

See [the Channel Layout section in the ffmpeg-utils(1) manual](ffmpeg-utils.html#channel-layout-syntax) for the required syntax.

If a parameter is omitted, all values are allowed.

Force the output to either unsigned 8-bit or signed 16-bit stereo

``` example-preformatted
aformat=sample_fmts=u8|s16:channel_layouts=stereo
```

### 8.27 afreqshift[\#](#afreqshift) [TOC](#toc-afreqshift)

Apply frequency shift to input audio samples.

The filter accepts the following options:

`shift`  
Specify frequency shift. Allowed range is -INT_MAX to INT_MAX. Default value is 0.0.

`level`  
Set output gain applied to final output. Allowed range is from 0.0 to 1.0. Default value is 1.0.

`order`  
Set filter order used for filtering. Allowed range is from 1 to 16. Default value is 8.

#### 8.27.1 Commands[\#](#Commands-10) [TOC](#toc-Commands-10)

This filter supports the all above options as [commands](#commands).

### 8.28 afwtdn[\#](#afwtdn) [TOC](#toc-afwtdn)

Reduce broadband noise from input samples using Wavelets.

A description of the accepted options follows.

`sigma`

Set the noise sigma, allowed range is from 0 to 1. Default value is 0. This option controls strength of denoising applied to input samples. Most useful way to set this option is via decibels, eg. -45dB.

`levels`

Set the number of wavelet levels of decomposition. Allowed range is from 1 to 12. Default value is 10. Setting this too low make denoising performance very poor.

`wavet`

Set wavelet type for decomposition of input frame. They are sorted by number of coefficients, from lowest to highest. More coefficients means worse filtering speed, but overall better quality. Available wavelets are:

‘`sym2`’

‘`sym4`’

‘`rbior68`’

‘`deb10`’

‘`sym10`’

‘`coif5`’

‘`bl3`’

`percent`

Set percent of full denoising. Allowed range is from 0 to 100 percent. Default value is 85 percent or partial denoising.

`profile`

If enabled, first input frame will be used as noise pro