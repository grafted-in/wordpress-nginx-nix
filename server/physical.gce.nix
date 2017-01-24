with import ./common.nix;

{ credentials, machineRegion, staticIpRegion }: {
  ${machineName} = {resources, ...}: {
    deployment.targetEnv = "gce";
    deployment.gce = credentials // {
      region       = machineRegion;
      instanceType = "n1-standard-1";
      tags         = ["public-http"];
      network      = resources.gceNetworks.main-net;
      ipAddress    = resources.gceStaticIPs.static-ip;
    };
  };

  resources.gceStaticIPs.static-ip = credentials // {
    region = staticIpRegion;
  };

  # NOTICE: GCE default network does not allow SSH access.
  #         Therefore it's vital that instances are first created
  #         with a custom network built by NixOps.
  resources.gceNetworks.main-net = credentials // {
    addressRange = "192.168.4.0/24";
    firewall = {
      allow-http = {
        targetTags   = ["public-http"];
        allowed.tcp  = [80 443];
        allowed.icmp = null;
      };
    };
  };
}
