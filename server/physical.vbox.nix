let
  machineTemplate = memoryGb: {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox = {
      memorySize = 1024 * memoryGb;
    };
  };
in {
  wordpress-main = machineTemplate 1;
}
