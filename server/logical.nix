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

    writeableDataPath = "/var/lib/phpfpm/${appConfig.name}";
    app = pkgs.callPackage ./app.nix {
      inherit appConfig;
      writeable = {
        sysPath = writeableDataPath;
        owner   = config.services.nginx.user;
      };
    };

    nginxConfig = import ./nginx-config.nix {
      inherit config pkgs acmeChallengesDir phpFpmListen;
      inherit (appConfig) enableHttps host hostRedirects;
      appRoot = "${app.package}";
      dhParams =           if appConfig.enableHttps        then "${config.security.dhparams.path}/nginx.pem" else null;
      pageSpeedCachePath = if enablePageSpeed              then "/run/nginx-pagespeed-cache" else null;
      fastCgiCachePath   = if appConfig.enableFastCgiCache then "/run/nginx-fastcgi-cache"   else null;
    };

    phpIni = import ./php-config.nix { inherit pkgs config appConfig; };
  in {
    networking = {
      hostName = machineName;
      firewall.allowedTCPPorts = [80] ++ pkgs.lib.optional appConfig.enableHttps 443;
    };

    environment.systemPackages = with pkgs; [
      gzip unzip nix-repl php vim zip
    ];

    time.timeZone = appConfig.timezone;

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
      phpOptions = phpIni;
      pools.wordpress-pool = import ./php-fpm-conf.nix { inherit config phpFpmListen; };
    };

    services.postfix.enable = true;

    systemd.services.init-writeable-paths = {
      description   = "Initialize writeable directories for the app";
      wantedBy      = [ "multi-user.target" "phpfpm.service" "nginx.service" ];
      after         = [ "network.target" ];
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = app.initScript;
      };
    };

    systemd.services.install-wp = {
      enable        = appConfig.autoInstall.enable;
      description   = "Configure WordPress installation with WP-CLI";
      before        = [ "nginx.service" ];
      after         = [ "init-writeable-paths.service" "mysql.service" ];
      wantedBy      = [ "multi-user.target" ];
      serviceConfig = {
        Type        = "oneshot";
        ExecStart   = import ./install-wp.nix {
          inherit pkgs config appConfig writeableDataPath;
          appPackage = app.package;
        };
      };
      environment.PHP_INI_SCAN_DIR = let
          customIni = pkgs.writeTextDir "wp-cli-custom.ini" phpIni;
        in "${pkgs.php}/etc:${customIni}";
    };
  }
  //
  (if !appConfig.enableHttps then {} else {
    security.acme.certs.${appConfig.host} = {
      webroot = acmeChallengesDir;
      email   = appConfig.adminEmail;
      postRun = "systemctl reload nginx.service";
    };

    # Depending on hardware, first-time deploy could take a good 5-15 minutes for this to generate.
    security.dhparams.params = { nginx = 3072; };
  });
}
