{ pkgs, config, phpFpmListen, processSettings }:
let
  setToString = (import ./utils.nix).setToString pkgs;
in
{
  listen = phpFpmListen;
  extraConfig = ''
    user  = ${config.services.nginx.user}
    group = ${config.services.nginx.group}

    listen.owner = ${config.services.nginx.user}
    listen.group = ${config.services.nginx.group}
    listen.mode = 660

    pm = dynamic
    ${setToString "\n" (setting: value: "pm.${setting} = ${toString value}") processSettings}

    ; Redirect worker stdout and stderr into main error log. If not set, stdout and
    ; stderr will be redirected to /dev/null according to FastCGI specs.
    ; Default Value: no
    catch_workers_output = yes
  '';
}
