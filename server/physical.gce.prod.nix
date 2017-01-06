import ./physical.gce.nix {
  credentials    = import ./gce.keys.nix;
  machineRegion  = "us-west1-a";
  staticIpRegion = "us-west1";
}
