{ lib, ... }: {
  options.modules.programs.shell = {
    enable = lib.mkEnableOption "Enable Shell Programs";
  };

  imports = [
    ./bash
    ./tools
  ];
}
