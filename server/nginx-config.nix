# References:
# https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/
# https://www.nginx.com/blog/9-tips-for-improving-wordpress-performance-with-nginx/
# https://easyengine.io/wordpress-nginx/tutorials/single-site/fastcgi-cache-with-purging/

{ config              # machine configuration
, pkgs

, host                # host for this site
, hostRedirects ? []  # list of hosts that redirect to the primary host
, appRoot             # root directory to serve
, enableHttps         # serve the site over HTTPS only?
, fastCgiCachePath    # path to fast CGI cache directory or `null` to disable the cache
, pageSpeedCachePath  # path to PageSpeed cache directory or `null` disable PageSpeed

, acmeChallengesDir   # directory where ACME (Let's Encrypt) challenges are stored
, phpFpmListen        # listen setting for PHP-FPM
}:
let

  isGiven = x: !(isNull x || x == "");
  enableFastCgiCache = isGiven fastCgiCachePath;
  enablePageSpeed    = isGiven pageSpeedCachePath;

  rootUrl = (if enableHttps then "https" else "http") + "://" + host;

  fullNginxConfig = ''
    ${if enableFastCgiCache then fastgciCachePart.cacheConfig else ""}
    ${if enableHttps then secureConfig else insecureConfig}
  '';

  secureConfig = ''
    server {
      server_name ${host};
      ${listenPart.insecure}

      location /.well-known/acme-challenge {
        root "${acmeChallengesDir}";
      }

      location / {
        return 301 https://${host}$request_uri;
      }
    }

    ${hostRedirectsConfig "https"}

    server {
      server_name ${host};
      ${listenPart.secure}

      ${tlsPart}
      ${serverPart}
    }
  '';

  insecureConfig = ''
    server {
      server_name ${host};
      ${listenPart.insecure}

      ${serverPart}
    }

    ${hostRedirectsConfig "http"}
  '';

  hostRedirectsConfig = targetScheme: pkgs.lib.optionalString (hostRedirects != []) ''
    server {
      server_name ${pkgs.lib.concatStringsSep " " hostRedirects};
      ${listenPart.insecure}
      return 301 ${targetScheme}://${host}$request_uri;
    }
  '';

  # Listen for both IPv4 & IPv6 requests with http2 enabled
  listenPart = {
    secure = ''
      listen 443 ssl http2;
      listen [::]:443 ssl http2;
    '';

    insecure = ''
      listen 80;
      listen [::]:80;
    '';
  };

  tlsPart = ''
    # SSL/TLS configuration, with TLS1 disabled
    ssl_certificate     ${config.security.acme.directory}/${host}/fullchain.pem;
    ssl_certificate_key ${config.security.acme.directory}/${host}/key.pem;
    ssl_protocols TLSv1.2 TLSv1.1;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4";
    ssl_session_timeout 30m;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;

    #ssl_dhparam /etc/ssl/certs/dhparam.pem;
  '';

  serverPart = ''
    root "${appRoot}";
    index index.html index.htm index.php;
    charset utf-8;

    # 301 Redirect URLs with trailing /'s as per https://webmasters.googleblog.com/2010/04/to-slash-or-not-to-slash.html
    #rewrite ^/(.*)/$ /$1 permanent;

    # Change // -> / for all URLs, so it works for our php location block, too
    merge_slashes off;
    rewrite (.*)//+(.*) $1/$2 permanent;

    # Access and error logging
    #access_log off;
    #error_log  /var/log/nginx/SOMEDOMAIN.com-error.log error;
    # If you want error logging to go to SYSLOG (for services like Papertrailapp.com), uncomment the following:
    #error_log syslog:server=unix:/dev/log,facility=local7,tag=nginx,severity=error;

    # Don't send the nginx version number in error pages and Server header
    server_tokens off;

    # Load configuration files from nginx-partials
    include ${./nginx-partials}/*.conf;

    # Root directory location handler
    location / {
      try_files $uri $uri/ /index.php?$query_string;
    }

    ${if enableFastCgiCache then fastgciCachePart.serverConfig else ""}

    # php-fpm configuration
    location ~ [^/]\.php(/|$) {
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass unix:${phpFpmListen};
      fastcgi_index index.php;

      include "${config.services.nginx.package}/conf/fastcgi.conf";
      fastcgi_param PATH_INFO       $fastcgi_path_info;
      fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;

      # Mitigate https://httpoxy.org/ vulnerabilities
      fastcgi_param HTTP_PROXY "";

      fastcgi_intercept_errors off;
      fastcgi_buffer_size 16k;
      fastcgi_buffers 4 16k;
      fastcgi_connect_timeout 300;
      fastcgi_send_timeout 300;
      fastcgi_read_timeout 300;

      ${if enableFastCgiCache then fastgciCachePart.phpCacheConfig else ""}
    }

    ${if enablePageSpeed then pageSpeedPart else ""}

    # Misc settings
    sendfile off;
    client_max_body_size 100m;
  '';

  fastgciCachePart = let
      cacheKeyPrefix = "$scheme$request_method$http_host";
    in {
      cacheConfig = ''
        # FastCGI Cache Settings
        fastcgi_cache_path "${fastCgiCachePath}" levels=1:2 keys_zone=WORDPRESS:100m inactive=60m;
        fastcgi_cache_key "${cacheKeyPrefix}$request_uri";
        fastcgi_cache_use_stale error timeout invalid_header http_500;
      '';

      serverConfig = ''
        # Configure FastCGI Cache
        set $skip_cache 0;

        # POST requests and URLs with a query string should always go to PHP
        if ($request_method = POST) {
          set $skip_cache 1;
        }
        if ($query_string != "") {
          set $skip_cache 1;
        }

        # Don't cache URIs containing the following segments.
        if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
          set $skip_cache 1;
        }

        # Don't use the cache for logged in users or recent commenters.
        # https://codex.wordpress.org/WordPress_Cookies
        if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
          set $skip_cache 1;
        }

        location ~ /purge(/.*) {
          fastcgi_cache_purge WORDPRESS "${cacheKeyPrefix}$1";
        }
      '';

      phpCacheConfig = ''
        # For testing the caching mechanism.
        add_header X-FastCGI-Cache $upstream_cache_status;

        fastcgi_cache_bypass $skip_cache;
        fastcgi_no_cache     $skip_cache;

        fastcgi_cache        WORDPRESS;
        fastcgi_cache_valid  60m;
      '';
    };

  pageSpeedPart = ''
    # PageSpeed configuration
    pagespeed on;
    pagespeed FileCachePath "${pageSpeedCachePath}";
    pagespeed LowercaseHtmlNames on;
    pagespeed RewriteLevel CoreFilters;
    pagespeed EnableFilters move_css_to_head,prioritize_critical_css,remove_comments,collapse_whitespace,trim_urls;
    pagespeed LoadFromFile "${rootUrl}/wp-content/" "${appRoot}/wp-content/";

    #pagespeed Statistics on;
    #pagespeed StatisticsLogging on;
    #pagespeed LogDir /var/log/nginx-pagespeed;
    #pagespeed AdminPath /pagespeed-admin;

    # Admin related blocks must preceed the other blocks.
    #location ~ "^/pagespeed-admin" {
    #  allow all;
    #}

    # Ensure requests for pagespeed optimized resources go to the pagespeed handler
    # and no extraneous headers get set.
    location ~ "\.pagespeed\.([a-z]\.)?[a-z]{2}\.[^.]{10}\.[^.]+" {
      add_header "" "";
    }
    location ~ "^/pagespeed_static/" { }
    location ~ "^/ngx_pagespeed_beacon$" { }
  '';

in fullNginxConfig
