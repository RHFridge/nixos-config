{ lib, config, pkgs, ... }:
let
  isQpc = config.vars.host == "qpc";
in {
  config = lib.mkIf config.modules.programs.llm.ollama.enable {
    services.ollama = lib.mkMerge [
      {
        enable = true;
        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          OLLAMA_KEEP_ALIVE = "2m";
        };
      }
      (lib.mkIf isQpc {
        package = pkgs.ollama-cuda;
        user = "ollama";
        group = "ollama";
        models = "/mnt/nvme/ollama/models";
        environmentVariables = {
          OLLAMA_CONTEXT_LENGTH = "65536";
          OLLAMA_MAX_LOADED_MODELS = "2";
        };
      })
      (lib.mkIf (!isQpc) {
        package = pkgs.ollama-vulkan;
        environmentVariables = {
          OLLAMA_CONTEXT_LENGTH = "16384";
          OLLAMA_MAX_LOADED_MODELS = "1";
        };
      })
    ];

    systemd.tmpfiles.rules = lib.mkIf isQpc [
      "d /mnt/nvme/ollama/models 0700 ollama ollama -"
    ];

    systemd.services.ollama.wantedBy = lib.mkForce [ ];
  };
}