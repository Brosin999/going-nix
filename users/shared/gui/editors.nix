{ pkgs, pkgs-unstable, ... }:
{
  home.packages = with pkgs; [
    pkgs-unstable.vscode
    obsidian
    libreoffice # CSV and office documents
  ];
}
