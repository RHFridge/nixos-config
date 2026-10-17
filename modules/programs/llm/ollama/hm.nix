{ pkgs, lib, config, ... }: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.llm.ollama.enable {
    home.packages = [ pkgs.opencode ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      permission = {
        edit = "ask";
        bash = "ask";
        webfetch = "ask";
      };
      model = "ollama/qwen3.8:27b";
      small_model = "ollama/qwen3.8:27b";
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options.baseURL = "http://localhost:11434/v1";
        models = {
          "qwen3.8:27b" = {
            name = "Qwen3.8 27B";
            limit = { context = 65536; output = 16384; };
          };
          "qwen3-coder:30b" = {
            name = "Qwen3 Coder 30B (fast)";
            limit = { context = 65536; output = 8192; };
          };
        };
      };
    };
  };
}