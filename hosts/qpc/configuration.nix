# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  config,
  ...
}: {
  imports = [
    ./vars.nix

    #Hardware
    "/etc/nixos/hardware-configuration.nix"
    ../../modules/hardware

    #Modules
    ../../modules/nixos/bundles/system.nix
    ../../modules/nixos/bundles/user-sys-packages.nix
    ../../modules/programs
    ../../modules/services
    ../../modules/desktop

    #Secrets
    ../../modules/sops/sops.nix

    #Home-Manager
    inputs.home-manager.nixosModules.default
  ];

  # Set hostname
  networking.hostName = config.vars.host;

  # Default user configuration
  users.users.${config.vars.user} = {
    isNormalUser = true;
    description = config.vars.user;
    initialPassword = "1234";
    hashedPasswordFile = config.sops.secrets.qpcpass.path;
    extraGroups = ["networkmanager" "wheel"];
  };

  # Set the system state version
  system.stateVersion = "25.11"; # Make sure this matches your installed version of NixOS
  
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  nix.settings = {
    max-jobs = 4;
    cores = 6;
  };
  

  modules = {
    system.hm.enable = true;
    hardware = {
      logitech.enable = true;
      microphone.enable = true;
      bluetooth.enable = true;
      gpu.nvidia.enable = true;
      printing.enable = true;
      scanner.enable = true;
      rgb.enable = true;
      network.enable = true;
    };

    desktop = {
      shells.enable = true;
      hyprland.enable = true;
      framework.enable = true;
    };

    programs = {
      shell.enable = true;

      browser.enable = true;

      comms = {
        enable = true;
        stoat.enable = false;
      };

      editors.enable = true;

      git.enable = true;

      filemanager.enable = true;

      games.enable = true;

      keepassxc.enable = true;

      multimedia.enable = true;

      ssh = {
        enable = true;
        server = {
          enable = true;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOHCNbgkn992QMb/n/64QDtkdzjkHAoPJxvQCQnDtcDK rhf@hp255"
          ];
        };
      };

      tealdeer.enable = true;

      terminal.enable = true;

      vpn.enable = true;
      
      llm.enable = true;
    };

    services.enable = true;
  };
}
