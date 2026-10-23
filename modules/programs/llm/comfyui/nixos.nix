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
  py = comfyPkg.python.pkgs;

  # SageAttention 1: pure Triton, no CUDA compile at build time
  sageattention = py.buildPythonPackage rec {
    pname = "sageattention";
    version = "1.0.6";
    pyproject = true;

    src = py.fetchPypi {
      inherit pname version;
      hash = "sha256-sDmKWHciLuGrrszSfRApMJyLV5lHlKEcEnjgv9F2USw=";
    };

    build-system = with py; [setuptools wheel];
    pypaBuildFlags = ["--skip-dependency-check"];

    dependencies = with py; [torch triton];

    doCheck = false;
    pythonImportsCheck = [];
  };

  # ComfyUI's own Python env plus extra deps for custom nodes
  comfyEnv = comfyPkg.pythonEnv.override (old: {
    extraLibs =
      old.extraLibs
      ++ (with py; [
        (opencv4.override {enableCuda = false;}) # Lucy-Edit-ComfyUI
        triton
      ])
      ++ [sageattention];
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
        ExecStart = "${comfyuiWithExtras}/bin/comfyui --base-directory /mnt/nvme/comfyui --listen 0.0.0.0 --port 8188 --disable-smart-memory --use-sage-attention";
        Restart = "on-failure";
      };
    };
  };
}