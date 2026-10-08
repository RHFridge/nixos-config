{ lib, config, ... }: {
  options.modules.programs.shell.tools = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.shell.enable;
      description = "Enable modern CLI tools (direnv, zoxide, fzf, eza, bat, starship...).";
    };
  };

  imports = [
    ./hm.nix
  ];
}
