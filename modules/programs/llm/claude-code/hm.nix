{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.llm.claude-code.enable {
    # Needed by Claude Code's bash sandbox on Linux.
    home.packages = with pkgs; [bubblewrap socat];

    programs.claude-code = {
      enable = true;
      # Unstable: Claude Code moves fast and the built-in updater can't touch the nix store.
      package = pkgs-unstable.claude-code;

      settings = {
        permissions = {
          # Every tool prompts before running. Nothing is pre-approved.
          defaultMode = "default";
          allow = [];
          ask = [
            "Bash"
            "Read"
            "Glob"
            "Grep"
            "Edit"
            "Write"
            "NotebookEdit"
            "WebFetch"
            "WebSearch"
          ];
          # Hard blocks: these can't be approved even when asked.
          deny = [
            # Secrets / keys
            "Read(~/.ssh/**)"
            "Read(~/.gnupg/**)"
            "Read(~/.config/sops/**)"
            "Read(/run/secrets/**)"
            "Read(/run/secrets.d/**)"
            "Read(**/.env)"
            "Read(**/.env.*)"
            "Read(**/secrets/**)"
            "Read(**/*.key)"
            "Read(**/*.pem)"
            "Edit(~/.ssh/**)"
            "Edit(~/.gnupg/**)"
            "Edit(~/.bashrc)"
            "Edit(~/.profile)"
            "Edit(~/.claude/**)"
            # Privilege escalation / system changes
            "Bash(sudo:*)"
            "Bash(doas:*)"
            "Bash(su:*)"
            "Bash(pkexec:*)"
            "Bash(nixos-rebuild:*)"
            "Bash(nh os:*)"
            "Bash(systemctl:*)"
            # Destructive / remote
            "Bash(rm -rf:*)"
            "Bash(dd:*)"
            "Bash(mkfs:*)"
            "Bash(shred:*)"
            "Bash(git push:*)"
            "Bash(ssh:*)"
            "Bash(scp:*)"
            "Bash(rsync:*)"
            "Bash(curl:*)"
            "Bash(wget:*)"
          ];
          # Can't switch to --dangerously-skip-permissions / bypass mode.
          disableBypassPermissionsMode = "disable";
        };

        # Run bash inside a bubblewrap sandbox (filesystem + network isolation),
        # and still ask before every command.
        sandbox = {
          enabled = true;
          autoAllowBashIfSandboxed = false;
          allowUnsandboxedCommands = false;
        };

        # Don't auto-trust MCP servers from project .mcp.json files.
        enableAllProjectMcpServers = false;

        env = {
          DISABLE_AUTOUPDATER = "1";
          DISABLE_TELEMETRY = "1";
          DISABLE_ERROR_REPORTING = "1";
          CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        };
      };
    };
  };
}