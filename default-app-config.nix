let
  lib = (import <nixpkgs> {}).lib;
in lib.makeExtensible (self: {
  domain = "wordpress-site.dev";

  # Simple name used for directories, etc.
  # WARNING: Changing this after a deployment will change the location of data directories and will
  #          likely result in a partial reset of your application. You must move data from the
  #          previous app folders to the new ones.
  name        = "wordpress-app";

  description = "A Wordpress Site";    # Brief, one-line description or title
  tagline     = "Deployed with Nixops";
  host        = "www.${self.domain}";
  adminEmail  = "admin@${self.domain}";

  siteUrl = "${if self.enableHttps then "https" else "http"}://${self.host}";

  # Hosts that get redirected to the primary host.
  hostRedirects = [self.domain];

  # Configure timezone settings (http://php.net/manual/en/timezones.php)
  timezone  = "UTC";

  # WP-CLI settings for automatic install
  autoInstall = let
      adminConfig = import ./wordpress-admin.keys.nix;
    in lib.makeExtensible (innerSelf: {
      enable = false;  # set to `true` to automatically install WordPress configuration
      inherit (adminConfig) adminUser adminPassword;
    });

  wordpress = import ./wordpress.nix;
  plugins   = import ./plugins.nix;
  themes    = import ./themes.nix;

  # Warning: Changing these after your site has been deployed will require manual
  #          work on the server. We don't want to do anything that would lose
  #          data so we leave that to you.
  freezeWordPress = true;  # Can admins upgrade WordPress in the CMS?
  freezePlugins   = true;  # Can admins edit plugins in the CMS?
  freezeThemes    = true;  # Can admins edit themes in the CMS?

  dbConfig = lib.makeExtensible (innerSelf: {
    isLocal     = true; # if `true`, MySQL will be installed on the server.
    name        = "wordpress";  # database name
    user        = "root";
    password    = "";
    host        = "localhost";
    charset     = "utf8mb4";
    tablePrefix = "wp_";
  });

  wpConfig = lib.makeExtensible (innerSelf: {
    # Generate this file with `curl https://api.wordpress.org/secret-key/1.1/salt/ > wordpress-keys.php.secret`
    secrets     = builtins.readFile ./wordpress-keys.php.secret;
    debugMode   = false;
    extraConfig = ''
        define('WP_HOME',    '${self.siteUrl}');
        define('WP_SITEURL', '${self.siteUrl}');
    '';

    inherit (self) dbConfig;

    template = import ./wp-config.nix;
    rendered = innerSelf.template innerSelf;
  });


  # Server settings
  enableHttps    = true;
  enableRollback = true;
  maxUploadMb    = 50;

  # --- ADVANCED CONFIGURATION ---
  extraTools = pkgs: [];  # Add tools to the server, e.g. [pkgs.git]

  imports = [];  # module imports for the server

  # raw nginx location directives to insert above the WordPress locations
  extraNginxLocations = pkgs: [];

  opcache = lib.makeExtensible (innerSelf: {
    enable            = true;
    maxMemoryMb       = 128;

    # How often to invalidate timestamp cache. This is only used when the project
    # has non-frozen components (see above).
    # http://php.net/manual/en/opcache.configuration.php#ini.opcache.revalidate-freq
    revalidateFreqSec = 60;
  });

  # PHP-FPM settings for the *dynamic* process manager: http://php.net/manual/en/install.fpm.configuration.php#pm
  phpFpmProcessSettings = lib.makeExtensible (innerSelf: {
    max_children      = 10;
    start_servers     = innerSelf.min_spare_servers;  # WARNING: min_spare_servers <= start_servers <= max_spare_servers
    min_spare_servers = 2;
    max_spare_servers = 5;
    max_requests      = 500;
  });

  googlePageSpeed = lib.makeExtensible (innerSelf: {
    enable    = true;
    cachePath = "/run/nginx-pagespeed-cache";  # /run/ is tmpfs and will keep cache in memory
  });

  fastCgiCache = lib.makeExtensible (innerSelf: {
    enable    = true;
    cachePath = "/run/nginx-fastcgi-cache"; # /run/ is tmpfs and will keep cache in memory
  });

  php = lib.makeExtensible (innerSelf: {
    enableXDebug = false;

    scriptMemoryLimitMb = 128;
    maxExecutionTimeSec = 300;

    # sendmail_path configuration for php.ini files
    sendmailPath = "/run/wrappers/bin/sendmail -t -i";
  });
})
