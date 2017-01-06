{ callPackage, fetchFromGitHub, fetchzip, lib, nginxModules, runCommand, stdenv
, enablePageSpeed
, ...
}:
let
  fastcgi-cache-purge = {
    src = fetchFromGitHub {
      owner  = "FRiCKLE";
      repo   = "ngx_cache_purge";
      rev    = "2.3";
      sha256 = "0ib2jrbjwrhvmihhnzkp4w87fxssbbmmmj6lfdwpm6ni8p9g60dw";
    };
  };

  pagespeed = let
    # Build instructions:
    # https://developers.google.com/speed/pagespeed/module/build_ngx_pagespeed_from_source
    # WARNING: This only works with Linux because the pre-built PSOL binary is only supplied for
    # Linux.
    # TODO: Build PSOL from source to support more platforms.

    version = "1.11.33.4";

    moduleSrc = fetchFromGitHub {
      owner  = "pagespeed";
      repo   = "ngx_pagespeed";
      rev    = "v${version}-beta";
      sha256 = "03dvzf1lgsjxcs1jjxq95n2rhgq0wy0f9ahvgascy0fak7qx4xj9";
    };

    psol = fetchzip {
      url    = "https://dl.google.com/dl/page-speed/psol/${version}.tar.gz";
      sha256 = "1jq2llp0i4666rwqnx1hs4pjlpblxivvs1jkkjzlmdbsv28jzjq8";
    };

    ngx_pagespeed = runCommand
      "ngx_pagespeed"
      {
        meta = { platforms = stdenv.lib.platforms.linux; };
      }
      ''
        cp -r "${moduleSrc}" "$out"
        chmod -R +w "$out"
        ln -s "${psol}" "$out/psol"
      '';

  in { src = ngx_pagespeed; };
in
callPackage <nixpkgs/pkgs/servers/http/nginx/mainline.nix> {
  modules = [
      nginxModules.dav
      nginxModules.moreheaders
      fastcgi-cache-purge
    ]
    ++ lib.optional enablePageSpeed pagespeed
  ;
}
