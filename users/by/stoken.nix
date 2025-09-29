{ pkgs, ... }:
{
  home.packages = with pkgs; [
    stoken
  ];
}