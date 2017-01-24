with import ./common.nix;

{ apiAuthToken, dropletRegion, dropletSize }: {
  resources.sshKeyPairs.ssh-key = {};

  ${machineName} = {...}: {
    deployment = {
      targetEnv = "digitalOcean";
      digitalOcean = {
        authToken = apiAuthToken;
        region    = dropletRegion;
        size      = dropletSize;
      };
    };
  };
}
