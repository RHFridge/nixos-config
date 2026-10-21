{ lib, config, ... }: {
  options.modules.programs.llm.claude-code = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.programs.llm.enable;
      description = "Enable Claude Code.";
    };
  };

  imports = [
    ./hm.nix
  ];
}