let
  domain = "wordpress-site.dev";
in rec {
  # Simple name used for directories, etc.
  # WARNING: Changing this after a deployment will change the location of data directories and will
  #          likely result in a partial reset of your application. You must move data from the
  #          previous app folders to the new ones.
  name        = "wordpress-app";

  description = "A Wordpress Site";    # Brief, one-line description or title
  host        = "www.${domain}";
  adminEmail  = "admin@${host}";

  # Hosts that get redirected to the primary host.
  hostRedirects = [domain];

  wordpress = import ./wordpress.nix;
  plugins   = import ./plugins.nix;
  themes    = import ./themes.nix;

  freezeWordPress = true;  # Can admins upgrade WordPress in the CMS?
  freezePlugins   = true;  # Can admins edit plugins in the CMS?
  freezeThemes    = true;  # Can admins edit themes in the CMS?

  dbConfig = {
    isLocal     = true; # if `true`, MySQL will be installed on the server.
    name        = "wordpress";  # database name
    user        = "root";
    password    = "";
    host        = "localhost";
    charset     = "utf8mb4";
    tablePrefix = "wp_";
  };

  wpConfig = import ./wp-config.nix {
    inherit dbConfig;
    # Generate this file with `curl https://api.wordpress.org/secret-key/1.1/salt/ > wordpress-keys.php.secret`
    secrets     = builtins.readFile ./wordpress-keys.php.secret;
    debugMode   = false;
    extraConfig = let
        siteUrl = if enableHttps then "https" else "http" + "://${host}";
      in ''
        define('WP_HOME',    '${siteUrl}');
        define('WP_SITEURL', '${siteUrl}');
    '';
  };

  # Server settings
  enableHttps        = true;
  enableOpCache      = true;
  enableFastCgiCache = true;
  enableRollback     = true;
}
