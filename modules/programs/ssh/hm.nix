{
  config,
  lib,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.ssh.enable {
    programs.ssh = {
      enable = true;

      # HM's implicit defaults are deprecated; spell out what we want in "*".
      enableDefaultConfig = false;

      includes = [ config.sops.secrets."ssh/hosts".path ];

      matchBlocks."*" = {
        # Keys get loaded into gcr-ssh-agent (from gnome-keyring) on first use.
        addKeysToAgent = "yes";
        hashKnownHosts = true;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        compression = false;
        forwardAgent = false;

        # Reuse one connection per host (faster repeat ssh/git operations).
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "10m";
      };
    };
  };
}
