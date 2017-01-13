{ callPackage, lib, nginxModules, enablePageSpeed, ... }:
callPackage <nixpkgs/pkgs/servers/http/nginx/mainline.nix> {
  modules = [
      nginxModules.dav
      nginxModules.fastcgi-cache-purge
      nginxModules.moreheaders
    ]
    ++ lib.optional enablePageSpeed nginxModules.pagespeed
  ;
}
