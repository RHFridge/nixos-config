{ lib, config, ... }: {
  options.modules.programs.shell.nautilusScripts = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.filemanager.nautilus.enable;
      description = "Install Nautilus scripts.";
    };
  };

  imports = [
    ./hm.nix
  ];
}
