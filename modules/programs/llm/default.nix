{ lib, ... }: {
  options.modules.programs.llm = {
    enable = lib.mkEnableOption "Enable LLMs";
  };

  imports = [
    ./ollama
    ./comfyui
    ./claude-code
  ];
}