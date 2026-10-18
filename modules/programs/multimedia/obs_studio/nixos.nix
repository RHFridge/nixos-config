{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.modules.programs.multimedia.obs-studio.enable {
    programs.obs-studio = with pkgs.obs-studio-plugins; {
      enable = true;
      package = (
        pkgs.obs-studio.override {
          cudaSupport = config.modules.hardware.gpu.nvidia.enable;
        }
      );
      plugins = [
        obs-pipewire-audio-capture
      ];
    };
  };
}
