{ lib, config, ... }: {
  options.modules.services.podman = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.services.enable;
      description = "Enable Podman service.";
    };
  };

  imports = [
    ./nixos.nix
  ];
}
