{ lib, config, ... }: {
  options.modules.programs.terminal.zellij = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.terminal.enable;
      description = "Enable Zellij terminal multiplexer.";
    };
  };

  imports = [
    ./hm.nix
  ];
}
