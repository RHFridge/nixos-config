{ lib, config, ... }: {
  options.modules.programs.llm.ollama = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.llm.enable;
      description = "Enable Ollama.";
    };
  };

  imports = [
    ./nixos.nix
    ./hm.nix
  ];
}
