{ lib, ... }: {
  options.modules.programs.ssh = {
    enable = lib.mkEnableOption "Enable SSH client configuration";

    server = {
      enable = lib.mkEnableOption "Enable the OpenSSH server (key-only auth)";
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ 22 ];
        description = "Ports sshd listens on (opened in the firewall).";
      };
      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Public keys allowed to log in as the main user.";
      };
    };
  };

  imports = [
    ./nixos.nix
    ./hm.nix
  ];
}
