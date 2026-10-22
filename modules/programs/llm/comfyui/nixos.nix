{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: let
  pkgsCuda = import pkgs-unstable.path {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };

  comfyPkg = pkgsCuda.comfyui;

  # ComfyUI's own Python env plus extra deps for custom nodes
  comfyEnv = comfyPkg.pythonEnv.override (old: {
    extraLibs =
      old.extraLibs
      ++ (with comfyPkg.python.pkgs; [
        (opencv4.override {enableCuda = false;}) # Lucy-Edit-ComfyUI
      ]);
  });

  comfyuiWithExtras = pkgs.writeShellApplication {
    name = "comfyui";
    text = ''
      unset PYTHONPATH NIX_PYTHONPATH
      exec ${comfyEnv}/bin/python ${comfyPkg}/share/comfyui/main.py "$@"
    '';
  };
in {
  config = lib.mkIf config.modules.programs.llm.comfyui.enable {
    systemd.tmpfiles.rules = [
      "d /mnt/sata/comfyui 0755 ${config.vars.user} users -"
    ];

    # Remove this if PhoneIP is already declared elsewhere in your config
    sops.secrets.PhoneIP = {};

    # Allow port 8188 only from the phone's IP, read from the secret at firewall start
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp \
        -s "$(cat ${config.sops.secrets.PhoneIP.path})" \
        --dport 8188 -j nixos-fw-accept
    '';

    systemd.services.comfyui = {
      description = "ComfyUI";
      serviceConfig = {
        User = config.vars.user;
        Group = "users";
        ExecStart = "${comfyuiWithExtras}/bin/comfyui --base-directory /mnt/nvme/comfyui --listen 0.0.0.0 --port 8188 --disable-smart-memory";
        Restart = "on-failure";
      };
    };
  };
}