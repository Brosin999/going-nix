{ pkgs, ... }:
let
  discord-web = pkgs.writeShellScriptBin "discord" ''
    mkdir -p "$HOME/.local/share/discord-web"
    ${pkgs.chromium}/bin/chromium \
      --user-data-dir="$HOME/.local/share/discord-web" \
      --class="Discord" \
      --name="Discord" \
      --app="https://discord.com/app" \
      --no-first-run \
      --no-default-browser-check \
      --disable-background-timer-throttling \
      --disable-renderer-backgrounding \
      --disable-backgrounding-occluded-windows \
      --password-store=basic
  '';
in
{
  home.packages = with pkgs; [
    firefox
    chromium
    discord-web
  ];

  # Create desktop entry for Discord web wrapper
  xdg.desktopEntries.discord = {
    name = "Discord";
    comment = "Discord Web App";
    exec = "${discord-web}/bin/discord";
    icon = "discord";
    categories = [ "Network" "InstantMessaging" ];
    startupNotify = true;
  };
}