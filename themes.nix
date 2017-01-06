# A list of your WordPress themes.
{ callPackage, ... }:
let
  utils = callPackage ../utils.nix {};
  getTheme = utils.getTheme;
in [
  (getTheme "twentyseventeen" "1.0" "01779xz4c3b1drv3v2d1p1rdh1w9a0wsxjxpvp4nzwm26h7bvg7n")
]
