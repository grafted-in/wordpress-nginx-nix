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
  host        = "www.${self.domain}";
  adminEmail  = "admin@${self.host}";

  # Hosts that get redirected to the primary host.
  hostRedirects = [self.domain];

  # Configure timezone settings (http://php.net/manual/en/timezones.php)
  timezone  = "UTC";

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
    extraConfig = let
        siteUrl = (if self.enableHttps then "https" else "http") + "://${self.host}";
      in ''
        define('WP_HOME',    '${siteUrl}');
        define('WP_SITEURL', '${siteUrl}');
    '';

    inherit (self) dbConfig;

    template = import ./wp-config.nix;
    rendered = innerSelf.template innerSelf;
  });


  # Server settings
  enableHttps        = true;
  enableOpCache      = true;
  enableFastCgiCache = true;
  enableRollback     = true;
})