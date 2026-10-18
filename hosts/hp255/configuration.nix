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
    hashedPasswordFile = config.sops.secrets.x280pass.path;
    extraGroups = ["networkmanager" "wheel"];
  };

  # Set the system state version
  system.stateVersion = "24.11"; # Make sure this matches your installed version of NixOS

  modules = {
    system.hm.enable = true;
    hardware = {
      logitech.enable = false;
      microphone.enable = false;
      bluetooth.enable = true;
      printing.enable = false;
      thunderbolt.enable = false;
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

      games = {
        prism-launcher.enable = true;
      };

      keepassxc.enable = true;

      multimedia = {
        enable = true;
        kdenlive.enable = false;
      };

      tealdeer.enable = true;

      terminal.enable = true;

      vpn = {
        enable = true;
        wireguard.enable = false;
      };

      llm.ollama.enable = true;
    };

    services.enable = true;
  };
}
