{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = with pkgs; [
    sops
  ];

  sops = {
    defaultSopsFile = "/home/${config.vars.user}/.config/sops/age/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${config.vars.user}/.config/sops/age/keys.txt";

    secrets = {
      x280pass.neededForUsers = true;
      qpcpass.neededForUsers = true;
      hspass.neededForUsers = true;
      "hp255/syncthing/key" = {};
      "hp255/syncthing/cert" = {};
      "qpc/syncthing/key" = {};
      "qpc/syncthing/cert" = {};
      "city" = {
        mode = "0440";
        owner = config.users.users.${config.vars.user}.name;
        group = config.users.users.${config.vars.user}.group;
      };
    };
  };
}
