{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode
    obsidian
    libreoffice # CSV and office documents
  ];
}
