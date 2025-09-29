{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ffmpeg              # Video/audio processing and webcam testing
    v4l-utils           # Video4Linux utilities for webcam control
  ];
}