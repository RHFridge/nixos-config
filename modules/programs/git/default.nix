{lib, ...}: let
  identityOpts = name: {
    dirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["~/Projects/${name}/"];
      description = ''
        Directories whose repos commit as the ${name} identity (fallback for
        repos with no matching remote). Trailing slash = everything below it.
      '';
    };
    sshKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "~/.ssh/id_ed25519_${name}";
      description = "SSH key used to push/pull as the ${name} identity. null = SSH defaults.";
    };
  };
in {
  # Per-repo git identity switching (personal vs alias).
  # Names, emails and GitHub usernames live in sops so this public repo never
  # contains (or links) the personal identity. See nixos.nix for the secret keys.
  options.modules.programs.git = {
    enable = lib.mkEnableOption "git with automatic personal/alias identity selection";
    personal = identityOpts "personal";
    alias = identityOpts "alias";
  };

  imports = [
    ./nixos.nix
    ./hm.nix
  ];
}
