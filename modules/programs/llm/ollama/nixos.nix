{
  lib,
  config,
  pkgs,
  ...
}: let
  isQpc = config.vars.host == "qpc";
  gpu = config.modules.hardware.gpu;

  ollamaPackage =
    if gpu.nvidia.enable
    then pkgs.ollama-cuda
    else if gpu.amd.enable
    then pkgs.ollama-vulkan
    else pkgs.ollama-cpu;
in {
  config = lib.mkIf config.modules.programs.llm.ollama.enable {
    services.ollama = lib.mkMerge [
      {
        enable = true;
        package = ollamaPackage;
        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          OLLAMA_KEEP_ALIVE = "2m";
        };
      }
      (lib.mkIf isQpc {
        user = "ollama";
        group = "ollama";
        models = "/mnt/nvme/ollama/models";
        environmentVariables = {
          OLLAMA_CONTEXT_LENGTH = "65536";
          OLLAMA_MAX_LOADED_MODELS = "2";
        };
      })
      (lib.mkIf (!isQpc) {
        environmentVariables = {
          OLLAMA_CONTEXT_LENGTH = "16384";
          OLLAMA_MAX_LOADED_MODELS = "1";
        };
      })
    ];

    systemd.tmpfiles.rules = lib.mkIf isQpc [
      "d /mnt/nvme/ollama/models 0700 ollama ollama -"
    ];

    systemd.services.ollama.wantedBy = lib.mkForce [];
  };
}
