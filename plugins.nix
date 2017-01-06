# A list of your WordPress plugins.
{ callPackage, ... }:
let
  utils = callPackage ../utils.nix {};
  getPlugin = utils.getPlugin;

  requiredPlugins = [
    (getPlugin "opcache"      "0.3.1" "18x6fnfc7ka4ynxv4z3rf4011ivqc0qy0dsd6i4lxa113jjyqz6d")
    (getPlugin "nginx-helper" "1.9.9" "12bij1qjx1s282akbh232lmfypg2xa5n9n7mb8g4widl0xabys6n")
  ];
in requiredPlugins ++ [
  (getPlugin "akismet" "3.2"   "0ri9a0lbr269r3crmsa6hn4v4nd4dyblrb0ffvkmig2pvvx25hyn")
  (getPlugin "jetpack" "4.4.2" "1xy6k0ijxnglab0l29ky2ik6h22vi4bz6c61r3jpca9m4f3lb3ml")
]
