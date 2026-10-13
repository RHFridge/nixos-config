{ lib, ... }: {
  options.modules.hardware.network = {
    enable = lib.mkEnableOption "Enable Network Settings";
  };

  imports = [
    ./nixos.nix
  ];
}
