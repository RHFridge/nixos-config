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

    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
