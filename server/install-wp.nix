{ pkgs
, config     # system configuration
, appConfig
, appPackage
, writeableDataPath
}:
pkgs.writeScript "install-wordpress.sh" ''
  #!${pkgs.stdenv.shell} -eu

  if ! $('${pkgs.wp-cli}/bin/wp' core is-installed --path='${appPackage}' --allow-root); then
    echo 'Installing WordPress configuration for ${appConfig.host}'
    '${pkgs.wp-cli}/bin/wp' core install \
      --url='${appConfig.siteUrl}' \
      --title='${appConfig.description}' \
      --admin_user='${appConfig.autoInstall.adminUser}' \
      --admin_password='${appConfig.autoInstall.adminPassword}' \
      --admin_email='${appConfig.adminEmail}' \
      --path='${appPackage}' \
      --allow-root;
    chown -R '${config.services.nginx.user}' '${writeableDataPath}';
  else
    echo 'WordPress configuration already installed for ${appConfig.host}'
  fi

  '${pkgs.wp-cli}/bin/wp' option update blogname '${appConfig.description}' \
    --path='${appPackage}' \
    --allow-root;

  '${pkgs.wp-cli}/bin/wp' option update blogdescription '${appConfig.tagline}' \
    --path='${appPackage}' \
    --allow-root;

  # TODO: Provide a list of plugins to be activated from plugins.nix
  '${pkgs.wp-cli}/bin/wp' plugin activate nginx-helper opcache \
    --path='${appPackage}' \
    --allow-root;
''
