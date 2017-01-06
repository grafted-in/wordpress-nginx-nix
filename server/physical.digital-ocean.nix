{ apiAuthToken, dropletRegion, dropletSize }: {
  resources.sshKeyPairs.ssh-key = {};

  wordpress-main = {...}: {
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
