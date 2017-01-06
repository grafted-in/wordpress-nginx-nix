{ fetchzip, runCommand, ... }:
let
  version = "4.7";
in fetchzip {
  url = "https://wordpress.org/wordpress-${version}.tar.gz";
  sha256 = "1sza9nm8dzlg7lfsl03lbsg8agaiwdycgz5dsdr17fm197hky3zb";
}
