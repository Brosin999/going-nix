{ pkgs, ... }:
{
  home.packages = with pkgs; [
    obsidian
    libreoffice # CSV and office documents
  ];
}
