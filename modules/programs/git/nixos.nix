{
  config,
  lib,
  ...
}: let
  cfg = config.modules.programs.git;
  user = config.users.users.${config.vars.user};

  # Stand-in for a secret's value; sops-nix swaps in the real value at activation.
  secret = name: config.sops.placeholder.${name};

  # Where a rendered template ends up (/run/secrets/rendered/<name>).
  renderedPath = name: config.sops.templates.${name}.path;

  # Git runs as the user, so the rendered files must be readable by them.
  userOwned = content: {
    inherit content;
    mode = "0400";
    owner = user.name;
    group = user.group;
  };

  # The [user] block and SSH command for one identity.
  identityConfig = id: let
    sshKey = cfg.${id}.sshKeyFile;
    # Always set sshCommand (plain `ssh` when there's no key), so a later
    # include fully replaces an earlier one instead of inheriting its key.
    sshCommand =
      if sshKey == null
      then "ssh"
      else "ssh -i ${sshKey} -o IdentitiesOnly=yes";
  in ''
    [user]
      name = ${secret "git/${id}/name"}
      email = ${secret "git/${id}/email"}
      signingKey = ${secret "git/${id}/signing-key"}
    [core]
      sshCommand = ${sshCommand}
  '';

  # Load an identity when any remote belongs to that GitHub user.
  remoteRules = id: let
    username = secret "git/${id}/github-user";
    identity = renderedPath "git-identity-${id}";
  in
    # First rule:  git@github.com:USER/repo  (also ~/.ssh/config host aliases)
    # Second rule: https://github.com/USER/repo  or  ssh://git@github.com/USER/repo
    ''
      [includeIf "hasconfig:remote.*.url:*:${username}/**"]
        path = ${identity}
      [includeIf "hasconfig:remote.*.url:*://*/${username}/**"]
        path = ${identity}
    '';
in {
  config = lib.mkIf cfg.enable {
    sops.templates = {
      git-identity-personal = userOwned (identityConfig "personal");
      git-identity-alias = userOwned (identityConfig "alias");

      # hm.nix includes this after the directory rules, so a matching
      # remote always beats the directory a repo lives in.
      git-remote-rules = userOwned (remoteRules "personal" + remoteRules "alias");
    };
  };
}
