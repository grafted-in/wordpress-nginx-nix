import ./physical.digital-ocean.nix {
  apiAuthToken  = (import ./digital-ocean.keys.nix).apiAuthToken;
  dropletRegion = "nyc3";   # https://developers.digitalocean.com/documentation/v2/#list-all-regions
  dropletSize   = "512mb";  # https://developers.digitalocean.com/documentation/v2/#list-all-sizes
}
