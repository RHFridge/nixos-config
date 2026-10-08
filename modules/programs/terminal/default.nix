{ lib, ... }: {
  options.modules.programs.terminal = {
    enable = lib.mkEnableOption "Enable Terminal Programs";
  };

  imports = [
    ./alacritty
    ./zellij
  ];
}
