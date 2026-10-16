{ config, pkgs, ... }:
{
  config = lib.mkIf config.modules.hardware.network.enable {
    hardware.enableRedistributableFirmware = true;
    networking.networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    hardware.wirelessRegulatoryDatabase = true;
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="GB"
    '';
  };
}