{ pkgs, lib, config, ... }:
let
  isQpc = config.vars.host == "qpc";

  provider = {
    npm = "@ai-sdk/openai-compatible";
    options.baseURL = "http://localhost:11434/v1";
  };

  qpcModels = {
    "qwen3.8:27b" = {
      name = "Qwen3.8 27B";
      limit = { context = 65536; output = 16384; };
    };
    "qwen3-coder:30b" = {
      name = "Qwen3 Coder 30B (fast)";
      limit = { context = 65536; output = 8192; };
    };
  };

  laptopModels = {
    "gpt-oss:20b" = {
      name = "gpt-oss 20B";
      limit = { context = 16384; output = 4096; };
    };
    "qwen3:8b" = {
      name = "Qwen3 8B";
      limit = { context = 16384; output = 4096; };
    };
    "qwen3.5:4b" = {
      name = "Qwen3.5 4B (quick)";
      limit = { context = 16384; output = 4096; };
    };
  };

  defaultModel = if isQpc then "ollama/qwen3.8:27b" else "ollama/gpt-oss:20b";
in {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.llm.ollama.enable {
    home.packages = [ pkgs.opencode ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      permission = {
        edit = "ask";
        bash = "ask";
        webfetch = "ask";
      };
      model = defaultModel;
      small_model = defaultModel;
      provider.ollama = provider // {
        name = if isQpc then "Ollama (RTX 3090)" else "Ollama (laptop)";
        models = if isQpc then qpcModels else laptopModels;
      };
    };
  };
}