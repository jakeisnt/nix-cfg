{ config, lib, pkgs, ... }:

# Calendar and contacts sync server
# Largely from https://nixos-mailserver.readthedocs.io/en/latest/howto-add-radicale.html
with lib;
with lib.my;
let
  cfg = config.modules.services.cal;
  domain = config.networking.domain;
  mailAccounts = config.mailserver.loginAccounts;
  htpasswd = pkgs.writeText "radicale.users" (concatStrings
    (flip mapAttrsToList mailAccounts (mail: user:
      mail + ":" + secrets.email.hashedPassword + "\n"
      ))
    );
in {
  options.modules.services.cal = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.radicale = {
      enable = true;
      config = ''
        [auth]
        type = htpasswd
        htpasswd_filename = ${htpasswd}
        htpasswd_encryption = bcrypt
      '';
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "cal.${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:5232/";
            extraConfig = ''
              proxy_set_header  X-Script-Name /;
              proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_pass_header Authorization;
            '';
          };
        };
      };
    };
  };
}
