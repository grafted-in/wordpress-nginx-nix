{ dbConfig
, secrets
, debugMode ? false
, extraConfig
}:
''
  <?php

  ${secrets}

  define('DB_NAME',     '${dbConfig.name}');
  define('DB_USER',     '${dbConfig.user}');
  define('DB_PASSWORD', '${dbConfig.password}');
  define('DB_HOST',     '${dbConfig.host}');
  define('DB_CHARSET',  '${dbConfig.charset}');
  $table_prefix = '${dbConfig.tablePrefix}';

  ${extraConfig}

  define('WP_DEBUG', ${if debugMode then "true" else "false"});

  define('ABSPATH', dirname(__FILE__) . '/');
  require_once(ABSPATH . 'wp-settings.php');
''
