{ config, lib, ... }:

with lib; {
  imports = [ ./private/default.nix ];
  time.timeZone = mkDefault "America/Los_Angeles";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";

  # for redshift mostly
  location = (if config.time.timeZone == "America/Los_Angeles" then {
    latitude = 43.70011;
    longitude = -79.4163;
  } else if config.time.timeZone == "Europe/Stockholm" then {
    latitude = 55.88;
    longitude = 12.5;
  } else
    { });
}
