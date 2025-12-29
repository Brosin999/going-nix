{ pkgs, ... }:
{
  home.packages = [
    pkgs.ollama-cuda
  ];
}
