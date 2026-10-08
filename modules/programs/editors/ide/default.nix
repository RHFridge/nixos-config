{ lib, config, ... }: let
  cfg = config.modules.programs;
in {
  options.modules.programs.editors.ide = {
    enable = lib.mkOption {
      type = lib.types.bool;
      # Needs all the pieces it glues together.
      default =
        cfg.editors.helix.enable
        && cfg.editors.yazi.enable
        && cfg.editors.lazygit.enable
        && cfg.terminal.zellij.enable;
      description = "Enable the `ide` command (Zellij layout: yazi sidebar + Helix + lazygit).";
    };
  };

  imports = [
    ./hm.nix
  ];
}
