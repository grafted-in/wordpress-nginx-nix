{ pkgs
, config  # system configuration
, appConfig
}:
''
  extension = "${pkgs.phpPackages.imagick}/lib/php/extensions/imagick.so"

  ${pkgs.lib.optionalString appConfig.opcache.enable ''
    zend_extension = "${config.services.phpfpm.phpPackage}/lib/php/extensions/opcache.so"
  ''}

  ${pkgs.lib.optionalString appConfig.enableXDebug ''
    ; WARNING: Be sure to load opcache *before* xdebug (http://us3.php.net/manual/en/opcache.installation.php).
    zend_extension = "${pkgs.phpPackages.xdebug}/lib/php/extensions/xdebug.so"
  ''}

  upload_max_filesize = ${toString appConfig.maxUploadMb}M
  date.timezone = "${appConfig.timezone}"
  sendmail_path = ${appConfig.phpSendmailPath}

  ${import ./opcache-config.nix (appConfig.opcache // {
    # Enable timestamp validation if the setup is not entirely frozen (managed by Nix).
    validateTimestamps = ! builtins.all (x: x)
      [appConfig.freezeWordPress appConfig.freezePlugins appConfig.freezeThemes];
  })}
''
