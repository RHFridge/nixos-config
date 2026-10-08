{ inputs
, pkgs
, lib
, config
, pkgs-unstable
, ...
}: {

  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];
  config = lib.mkIf config.modules.desktop.shells.noctalia.enable {
    environment.systemPackages = [
      pkgs.noctalia
      pkgs.noctalia-greeter
    ];

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        keyboard.layout = "gb";
      };
    };
  };
}
