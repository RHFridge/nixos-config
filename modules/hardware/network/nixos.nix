{ config, pkgs, ... }:
{
  hardware.enableRedistributableFirmware = true;
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="GB"
  '';
}