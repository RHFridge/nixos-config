{
  pkgs,
  lib,
  config,
  ...
}: let
  isQpc = config.vars.host == "qpc";

  qpcModels = {
    "qwen3.8:27b" = {
      name = "Qwen3.8 27B";
      limit = {
        context = 65536;
        output = 16384;
      };
    };
    "qwen3-coder:30b" = {
      name = "Qwen3 Coder 30B (fast)";
      limit = {
        context = 65536;
        output = 8192;
      };
    };
  };

  laptopModels = {
    "qwen3:8b" = {
      name = "Qwen3 8B";
      limit = {
        context = 16384;
        output = 4096;
      };
      options = {
        temperature = 0.6;
        top_p = 0.95;
      };
    };
    "gpt-oss:20b" = {
      name = "gpt-oss 20B";
      limit = {
        context = 16384;
        output = 4096;
      };
    };
    "qwen3.5:4b" = {
      name = "Qwen3.5 4B (quick)";
      limit = {
        context = 16384;
        output = 4096;
      };
    };
  };

  defaultModel =
    if isQpc
    then "ollama/qwen3.8:27b"
    else "ollama/qwen3:8b";
in {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.llm.ollama.enable {
    home.packages = [pkgs.opencode];

    xdg.configFile."opencode/prompts/lite.txt" = lib.mkIf (!isQpc) {
      text = ''
        You are a coding assistant working in the user's project directory.
        Be concise. Read only the files you need. Make small, targeted edits.
        Explain what you changed in one or two sentences.
      '';
    };

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON ({
        "$schema" = "https://opencode.ai/config.json";
        permission = {
          edit = "ask";
          bash = "ask";
          webfetch = "ask";
        };
        model = defaultModel;
        small_model = defaultModel;
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name =
              if isQpc
              then "Ollama (RTX 3090)"
              else "Ollama (laptop)";
            options.baseURL = "http://localhost:11434/v1";
            models =
              if isQpc
              then qpcModels
              else laptopModels;
          };
          anthropic.models = {
            "claude-sonnet-5-5" = {name = "Claude Sonnet 5.5";};
            "claude-opus-5-5" = {name = "Claude Opus 5.5";};
            "claude-haiku-5-5" = {name = "Claude Haiku 5.5";};
          };
        };
      }
      // lib.optionalAttrs (!isQpc) {
        agent.lite = {
          description = "Lightweight agent for slow local models";
          mode = "primary";
          model = "ollama/qwen3:8b";
          prompt = "{file:./prompts/lite.txt}";
          tools = {
            webfetch = false;
            task = false;
            todowrite = false;
            todoread = false;
            patch = false;
            list = false;
          };
        };
      });
  };
}
