{ fetchzip, runCommand, ... }:
let
  version = "4.7.1";
in fetchzip {
  url = "https://wordpress.org/wordpress-${version}.zip";
  sha256 = "0n4j8yl5d903iaa197asn437907nscfl74j90jk3ql5pns8qckm5";
}
