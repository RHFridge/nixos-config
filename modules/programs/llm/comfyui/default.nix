{ lib, config, ... }: {
  options.modules.programs.llm.comfyui = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.llm.enable;
      description = "Enable ComfyUI.";
    };
  };

  imports = [
    ./nixos.nix
  ];
}
