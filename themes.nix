# A list of your WordPress themes.
{ callPackage, ... }:
let
  utils = callPackage ./utils.nix {};
  getTheme = utils.getTheme;
in [
  (getTheme "twentyseventeen" "1.1" "1xsdz1s68mavz9i4lhckh7rqw266jqm5mn3ql1gbz03zf6ghf982")
]
