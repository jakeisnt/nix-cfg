{ config, options, lib, pkgs, secrets, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.media.ncmpcpp;
  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-with-extensions";
    paths = closePropagation
      (with pkgs; [ mopidy-spotify mopidy-youtube mopidy-mpd ]);
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };
in {
  options.modules.media.ncmpcpp = { enable = mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      ncmpcpp
      (writeScriptBin "mpd" ''
        #!${stdenv.shell}
        exec ${mopidyEnv}/bin/mopidy & disown
      '')
    ];

    # as a systemd service, mopidy can't properly connect to pulseaudio
    # so this is on hold until that's figured out.
    # systemd.services.mopidy = {
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "network.target" "sound.target" "network-online.target" ];
    #   description = "mopidy music player daemon";
    #   serviceConfig = {
    #     ExecStart = "${mopidyEnv}/bin/mopidy";
    #     User = "jake";
    #   };
    # };

    # the official mopidy service has the same problem,
    # and another: when mopidy is running as a privileged user,
    # it by default pulls its configuration from /etc (with no way
    # to reconfigure for the official nixos package), which
    # is inconsistent with what we want for our configuration.

    env.NCMPCPP_HOME = "$XDG_CONFIG_HOME/ncmpcpp";

    # Symlink these one at a time because ncmpcpp writes other files to
    # ~/.config/ncmpcpp, so it needs to be writeable.
    home.configFile = {
      "ncmpcpp/config".source = "${configDir}/ncmpcpp/config";
      "ncmpcpp/bindings".source = "${configDir}/ncmpcpp/bindings";
      # "mopidy/mopidy.conf".source = "${configDir}/mopidy/mopidy.conf";
      "mopidy/mopidy.conf".text = with secrets;
        concatStringsSep "\n" [
          (concatMapStringsSep "\n" readFile [ ./config/mopidy/mopidy.conf ])
          ''
            username=${SPOTIFY_USERNAME}
            password=${SPOTIFY_PASSWORD}
            client_id=${SPOTIFY_CLIENT_ID}
            client_secret=${SPOTIFY_CLIENT_SECRET}
            [soundcloud]
            auth_token=${SOUNDCLOUD_AUTH_TOKEN}\n''
        ];
    };
  };
}
