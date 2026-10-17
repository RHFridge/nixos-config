{ lib, config, pkgs , ... }: {
  config = lib.mkIf config.modules.programs.llm.ollama.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      environmentVariables = {
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        OLLAMA_CONTEXT_LENGTH = "32768";
        OLLAMA_KEEP_ALIVE = "2m";
      };
    };

    systemd.services.ollama.wantedBy = lib.mkForce [ ];
    services.ollama.models = lib.mkIf (config.vars.host == "qpc") "/mnt/nvme/ollama/models";
  };
}
