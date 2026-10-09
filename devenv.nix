{ pkgs, ... }:

# The ffmpeg-music studio: the instrument (ffmpeg 9.0.1, exact build) and the listening tools.
# Entering the shell also GC-roots the ffmpeg outputs, so the build the pieces depend on
# is never garbage-collected.
{
  packages = [
    pkgs.ffmpeg        # bin output: ffmpeg, ffplay, ffprobe — the instrument
    pkgs.ffmpeg.lib    # libavcodec & co. — studio 400 reads its tables in place
    pkgs.python3       # perform.py, the composers' analysis tools
    pkgs.fzf           # browse.sh
    pkgs.chafa         # spectrograms in the terminal
    pkgs.vhs           # scripted terminal recordings for release assets (scripts/release.sh)
  ];

  env.FFMPEG_MUSIC_LIB = "${pkgs.ffmpeg.lib}";
  env.FFMPEG_MUSIC_BIN = "${pkgs.ffmpeg.bin}/bin/ffmpeg";

  enterShell = ''
    export PATH="$DEVENV_ROOT/scripts:$PATH"
    echo "ffmpeg-music: scripts/browse.sh · scripts/play.sh NNN · scripts/perform.py instruments/diatonic-live.sh"
  '';
}
