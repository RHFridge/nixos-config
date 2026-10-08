{
  config,
  lib,
  pkgs,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.shell.tools.enable {
    programs = {
      # Per-project dev shells: drop a `.envrc` with `use flake` (or `use nix`)
      # in a repo, run `direnv allow`, and the toolchain loads when you cd in.
      # Helix launched from that shell sees the same LSPs/compilers.
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };

      # `z proj` jumps to the most-used dir matching "proj"; `zi` = fuzzy pick.
      zoxide.enable = true;

      # Ctrl+r fuzzy history, Ctrl+t fuzzy file, Alt+c fuzzy cd.
      fzf = {
        enable = true;
        defaultCommand = "fd --type f --hidden --exclude .git";
        fileWidgetCommand = "fd --type f --hidden --exclude .git";
        changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
      };

      eza = {
        enable = true;
        icons = "auto";
        git = true;
        # adds ls / ll / la / lt aliases
        enableBashIntegration = true;
      };

      bat.enable = true;
      btop.enable = true;

      starship = {
        enable = true;
        settings = {
          format = "\n[\\[$username@$hostname:$directory\\]](bold green)$git_branch$git_status$nix_shell$cmd_duration$character";
          add_newline = false;
          username = {
            show_always = true;
            format = "$user";
          };
          hostname = {
            ssh_only = false;
            format = "$hostname";
          };
          directory = {
            format = "$path";
            truncation_length = 0; # never shorten the path
            truncate_to_repo = false; # full path inside git repos too
          };
          git_branch.format = " [\\($branch\\)]($style)";
          git_status.format = "( [$all_status$ahead_behind]($style))";
          nix_shell.format = " [$symbol]($style)";
          cmd_duration = {
            min_time = 2000;
            format = " [$duration]($style)";
          };
          character = {
            success_symbol = "[\\$](bold green)";
            error_symbol = "[\\$](bold red)";
          };
        };
      };
    };

      home.packages = with pkgs; [
        fd
        ripgrep
        jq
        dust # `dust` = what's using my disk
      ];

      home.shellAliases = {
        cat = "bat --paging=never --style=plain";
      };
    };
  }
