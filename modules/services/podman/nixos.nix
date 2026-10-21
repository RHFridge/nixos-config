{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.modules.services.podman.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
    
    hardware.nvidia-container-toolkit.enable = config.modules.hardware.gpu.nvidia.enable;

    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
