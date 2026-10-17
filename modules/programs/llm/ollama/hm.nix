{ pkgs, lib, config, ... }: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.llm.ollama.enable {
    home.packages = [ pkgs.opencode ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "ollama/qwen3-coder:30b";
      small_model = "ollama/qwen3-coder:30b";
      provider.ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options.baseURL = "http://localhost:11434/v1";
        models = {
          "qwen3-coder:30b" = {
            name = "Qwen3 Coder 30B";
            limit = { context = 32768; output = 8192; };
          };
          "qwen3.5:27b" = {
            name = "Qwen 3.5 27B";
            limit = { context = 32768; output = 8192; };
          };
        };
      };
    };
  };
}