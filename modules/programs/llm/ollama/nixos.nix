{ lib, config, pkgs, ... }: {
  config = lib.mkIf config.modules.programs.llm.ollama.enable {
    services.ollama = lib.mkMerge [
      {
        enable = true;
        package = pkgs.ollama-cuda;
        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          OLLAMA_CONTEXT_LENGTH = "65536";
          OLLAMA_KEEP_ALIVE = "2m";
        };
      }
      (lib.mkIf (config.vars.host == "qpc") {
        user = "ollama";
        group = "ollama";
        models = "/mnt/nvme/ollama/models";
      })
    ];

    systemd.tmpfiles.rules = lib.mkIf (config.vars.host == "qpc") [
      "d /mnt/nvme/ollama/models 0700 ollama ollama -"
    ];

    systemd.services.ollama.wantedBy = lib.mkForce [ ];
  };
}