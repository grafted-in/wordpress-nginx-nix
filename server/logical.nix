# Logical definition of our server

with import ./common.nix;

overrideFn: # a function of the form (self: super: { ... })
            # to override defaults in default-app-config.nix
let
  appConfig = (import ../default-app-config.nix).extend overrideFn;
in {
  network = {
    inherit (appConfig) enableRollback description;
  };

  ${machineName} = { config, pkgs, ... }: let
    # This is not being used but can be useful for testing/development:
    phpTestIndex = pkgs.writeTextDir "index.php" "<?php var_export($_SERVER)?>";

    defaultDbSetup = pkgs.writeText "default-db-setup.sql" ''
      SET NAMES ${appConfig.dbConfig.charset};
    '';

    acmeChallengesDir = "/var/www/challenges";
    phpFpmListen      = "/run/phpfpm/wordpress-pool.sock";
    enablePageSpeed   = pkgs.stdenv.isLinux;

    app = pkgs.callPackage ./app.nix {
      inherit appConfig;
      writeable = {
        sysPath = "/var/lib/phpfpm/${appConfig.name}";
        owner   = config.services.nginx.user;
      };
    };

    nginxConfig = import ./nginx-config.nix {
      inherit config pkgs acmeChallengesDir phpFpmListen;
      inherit (appConfig) enableHttps host hostRedirects;
      appRoot = "${app.package}";
      pageSpeedCachePath = if enablePageSpeed              then "/run/nginx-pagespeed-cache" else null;
      fastCgiCachePath   = if appConfig.enableFastCgiCache then "/run/nginx-fastcgi-cache"   else null;
    };
  in {
    networking = {
      hostName = machineName;
      firewall.allowedTCPPorts = [80] ++ pkgs.lib.optional appConfig.enableHttps 443;
    };

    environment.systemPackages = with pkgs; [
      gzip unzip nix-repl php vim zip
    ];

    services.nginx = {
      enable     = true;
      package    = pkgs.callPackage ./nginx.nix { inherit enablePageSpeed; };
      httpConfig = nginxConfig;
    };

    services.mysql = {
      enable  = appConfig.dbConfig.isLocal;
      package = pkgs.mysql;  # actually MariaDB

      initialDatabases = [
        {
          name   = appConfig.dbConfig.name;
          schema = defaultDbSetup;
        }
      ];
    };

    services.phpfpm = {
      phpOptions = ''
        extension      = "${pkgs.phpPackages.imagick}/lib/php/extensions/imagick.so"
        zend_extension = "${config.services.phpfpm.phpPackage}/lib/php/extensions/opcache.so"

        ; WARNING: Be sure to load opcache *before* xdebug (http://us3.php.net/manual/en/opcache.installation.php).
        zend_extension = "${pkgs.phpPackages.xdebug}/lib/php/extensions/xdebug.so"

        sendmail_path = ${pkgs.postfix}/bin/sendmail -t -i

        ${import ./opcache-config.nix { enabled = appConfig.enableOpCache; }}
      '';

      pools.wordpress-pool = import ./php-fpm-conf.nix { inherit config phpFpmListen; };
    };

    services.postfix.enable = true;

    systemd.services.init-writeable-paths = {
      description   = "Initialize writeable directories for the app";
      wantedBy      = [ "multi-user.target" "phpfpm" "nginx" ];
      after         = [ "network.target" ];
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = app.initScript;
      };
    };
  } // (
    if appConfig.enableHttps then {
      security.acme.certs.${appConfig.host} = {
        webroot = acmeChallengesDir;
        email   = appConfig.adminEmail;
        postRun = "systemctl reload nginx.service";
      };
    } else {}
  );
}
