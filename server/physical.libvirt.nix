with import ./common.nix;

let
  machineTemplate = memoryMb: {
    deployment.targetEnv = "libvirtd";
    deployment.libvirtd = {
      headless   = true;
      memorySize = memoryMb;
    };
  };
in {
  ${machineName} = machineTemplate 1024;
}
