{ lib, config, ... }: {
  options.modules.programs.editors.yazi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.editors.enable;
      description = "Enable yazi.";
    };
  };

  imports = [
    ./hm.nix
  ];
}
