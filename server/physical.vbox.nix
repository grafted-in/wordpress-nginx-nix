with import ./common.nix;

let
  machineTemplate = memoryMb: {
    deployment.targetEnv = "virtualbox";
    deployment.virtualbox = {
      headless   = true;
      memorySize = memoryMb;
    };
  };
in {
  ${machineName} = machineTemplate 1024;
}
