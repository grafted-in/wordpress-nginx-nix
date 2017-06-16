{ fetchzip, runCommand, ... }:
let
  version = "4.8";
in fetchzip {
  url    = "https://wordpress.org/wordpress-${version}.tar.gz";
  sha256 = "1myflpa9pxcghnhjfd0ahqpsvgcwh3szk2k8w2x7qmvfll69n3j9";
}
