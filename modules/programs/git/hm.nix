{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.git;
  rendered = name: config.sops.templates."git-${name}".path;

  dirRules = id:
    map (dir: {
      condition = "gitdir:${dir}";
      path = rendered "identity-${id}";
    })
    cfg.${id}.dirs;
in {
  home-manager.users.${config.vars.user} = lib.mkIf cfg.enable {
    programs.gpg.enable = true;

    # Caches the passphrase; prompts with a GTK dialog (uses gcr from gnome-keyring).
    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
    };

    programs.git = {
      enable = true;

      # Sign every commit and tag with GPG. The key itself comes from the
      # identity file (user.signingKey), so each account signs with its own key.
      signing = {
        format = "openpgp";
        signByDefault = true;
      };

      settings = {
        # No global identity on purpose: if neither a remote nor a directory
        # rule matches, git refuses to commit instead of guessing and
        # cross-linking the two accounts.
        user.useConfigOnly = true;
        alias.whoami = "!git config user.name; git config user.email";
      };

      # Order matters: later includes win. Directory rules first, then the
      # remote rules, so the remote URL is authoritative when it matches.
      includes =
        dirRules "personal"
        ++ dirRules "alias"
        ++ [{path = rendered "remote-rules";}];
    };
  };
}