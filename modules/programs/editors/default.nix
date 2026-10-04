{ lib, ... }: {
  options.modules.programs.editors = {
    enable = lib.mkEnableOption "Enable Editor Programs";
  };

  imports = [
    ./vscode
    ./helix
    ./lf
    ./dbeaver
  ];
}
