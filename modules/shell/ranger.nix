{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.ranger;
in {
  options.modules.shell.ranger = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ranger
      w3m
      viu # viu image preview
      poppler_utils # pdf preview
      ffmpegthumbnailer # video thumbnails
    ];

    home.configFile = {
      "ranger" = {
        source = "${configDir}/ranger";
        recursive = true;
      };
    };
  };
}
