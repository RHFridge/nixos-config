{ lib, ... }: {
  options.modules.services = {
    enable = lib.mkEnableOption "Enable Services";
  };

  imports = [
    ./android
    ./nfs
    ./flatpak
    ./syncthing
    ./distrobox
    ./podman
  ];
}
