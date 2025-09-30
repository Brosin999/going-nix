{ pkgs, ... }:
let
  makeWebApp = name: url: icon: categories: pkgs.writeShellScriptBin (pkgs.lib.toLower name) ''
    mkdir -p "$HOME/.local/share/${pkgs.lib.toLower name}-web"
    ${pkgs.chromium}/bin/chromium \
      --user-data-dir="$HOME/.local/share/${pkgs.lib.toLower name}-web" \
      --class="${name}" \
      --name="${name}" \
      --app="${url}" \
      --no-first-run \
      --no-default-browser-check \
      --disable-background-timer-throttling \
      --disable-renderer-backgrounding \
      --disable-backgrounding-occluded-windows \
      --password-store=basic
  '';

  # Define web apps here
  webApps = [
    { name = "Discord"; url = "https://discord.com/app"; icon = "discord"; categories = [ "Network" "InstantMessaging" ]; }
    { name = "Teams"; url = "https://teams.microsoft.com.mcas.ms/v2"; icon = "teams"; categories = [ "InstantMessaging" ]; }
    { name = "Outlook"; url = "https://outlook.office.com.mcas.ms/mail/"; icon = "teams"; categories = [ "InstantMessaging"]; }
  ];

  # Generate packages and desktop entries
  webAppPackages = map (app: makeWebApp app.name app.url app.icon app.categories) webApps;
  webAppDesktopEntries = builtins.listToAttrs (map (app: {
    name = pkgs.lib.toLower app.name;
    value = {
      name = app.name;
      comment = "${app.name} Web App";
      exec = "${makeWebApp app.name app.url app.icon app.categories}/bin/${pkgs.lib.toLower app.name}";
      icon = app.icon;
      categories = app.categories;
      startupNotify = true;
    };
  }) webApps);
in
{
  home.packages = with pkgs; [
    firefox
    chromium
  ] ++ webAppPackages;

  xdg.desktopEntries = webAppDesktopEntries;
}
