{ fetchzip, runCommand, ... }:
let
  version = "4.7.3";
in fetchzip {
  url    = "https://wordpress.org/wordpress-${version}.tar.gz";
  sha256 = "08val9zlid2swi0c46xh9hyjmd8visdsq4q2fdrjvvm38qazhsgl";
}
