{ config, phpFpmListen }:
{
  listen = phpFpmListen;
  extraConfig = ''
    user  = ${config.services.nginx.user}
    group = ${config.services.nginx.group}

    listen.owner = ${config.services.nginx.user}
    listen.group = ${config.services.nginx.group}
    listen.mode = 660

    pm = dynamic
    pm.max_children      = 10
    pm.start_servers     = 5
    pm.min_spare_servers = 2
    pm.max_spare_servers = 5
    pm.max_requests      = 500

    ; Redirect worker stdout and stderr into main error log. If not set, stdout and
    ; stderr will be redirected to /dev/null according to FastCGI specs.
    ; Default Value: no
    catch_workers_output = yes
  '';
}
