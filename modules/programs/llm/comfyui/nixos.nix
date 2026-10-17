{ lib, config, pkgs, pkgs-unstable, ... }: {
  config = lib.mkIf config.modules.programs.llm.comfyui.enable {
    systemd.tmpfiles.rules = [
      "d /mnt/sata/comfyui 0755 ${config.vars.user} users -"
    ];

    systemd.services.comfyui = {
      description = "ComfyUI";
      serviceConfig = {
        User = config.vars.user;
        Group = "users";
        ExecStart = "${(import pkgs-unstable.path {
          system = pkgs.stdenv.hostPlatform.system;
          config = { allowUnfree = true; cudaSupport = true; };
        }).comfyui}/bin/comfyui --base-directory /mnt/nvme/comfyui --listen 127.0.0.1 --port 8188";
        Restart = "on-failure";
      };
    };
  };
}