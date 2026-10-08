{ lib, config, ... }: {
  options.modules.programs.editors.lf = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false; # superseded by yazi
      description = "Enable lf.";
    };
  };

  imports = [
    ./hm.nix
  ];
}
