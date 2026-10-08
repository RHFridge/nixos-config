{ lib, config, ... }: {
  options.modules.programs.editors.lazygit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.editors.enable;
      description = "Enable lazygit.";
    };
  };

  imports = [
    ./hm.nix
  ];
}
