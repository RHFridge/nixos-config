{ lib, config, ... }: {
  options.modules.programs.editors.dbeaver = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.editors.enable;
      description = "Enable DBeaver editor.";
    };
  };

  imports = [
    ./hm.nix
  ];
}
