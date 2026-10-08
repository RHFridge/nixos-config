{
  pkgs,
  config,
  lib,
  ...
}: let
  # Yazi as a full-screen file picker *inside* Helix (Ctrl+y).
  # Pattern from the Yazi docs; needs Helix >= 25.07 for %{} / %sh{} expansions.
  yaziPicker = [
    ":sh rm -f /tmp/helix-yazi-chooser"
    ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/helix-yazi-chooser"
    # restore Helix's alternate screen + bracketed paste after the TUI exits
    ":insert-output printf '\\033[?1049h\\033[?2004h' > /dev/tty"
    ":open %sh{cat /tmp/helix-yazi-chooser}"
    ":redraw"
  ];

  # Lazygit full-screen inside Helix (Ctrl+g). Saves first, reloads after so
  # checkouts / stashes / discards show up straight away.
  lazygit = [
    ":write-all"
    ":new"
    ":insert-output lazygit"
    # restore Helix's alternate screen + bracketed paste after the TUI exits
    ":insert-output printf '\\033[?1049h\\033[?2004h' > /dev/tty"
    ":buffer-close!"
    ":redraw"
    ":reload-all"
  ];
in {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.editors.helix.enable {
    # Silk-dark colours from Stylix, same as the rest of the desktop.
    stylix.targets.helix.enable = true;

    programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        editor = {
          line-number = "relative";
          mouse = false;
          cursorline = true;
          color-modes = true;
          bufferline = "multiple"; # VS Code-style tabs once >1 file is open
          true-color = true;
          rulers = [100];
          end-of-line-diagnostics = "hint";
          inline-diagnostics.cursor-line = "warning";
          lsp = {
            display-inlay-hints = true;
            display-messages = true;
          };
          indent-guides = {
            render = true;
            character = "╎";
            skip-levels = 1;
          };
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false; # show dotfiles (still respects .gitignore)
          statusline = {
            left = ["mode" "spinner" "version-control" "file-name" "file-modification-indicator"];
            center = [];
            right = ["diagnostics" "selections" "register" "position" "file-encoding" "file-type"];
          };
          auto-save = {
            focus-lost = true;
            after-delay = {
              enable = true;
              timeout = 3000;
            };
          };
        };

        keys.normal = {
          C-y = yaziPicker;
          C-g = lazygit;
          space = {
            # Built-in, already bound: space e / space E = file explorer,
            # space g = changed-files picker, space f = file picker,
            # gn / gp = next / previous buffer.
            x = ":buffer-close"; # close the current "tab"
            B = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
          };
        };
      };

      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "alejandra";
            };
            language-servers = ["nil"];
          }
          {
            name = "bash";
            auto-format = true;
            formatter = {
              command = "shfmt";
              args = ["-i" "2"];
            };
          }
        ];
      };

      # Language servers Helix will pick up automatically (`hx --health` to check).
      extraPackages = with pkgs; [
        # Nix
        nil
        alejandra
        # C# (Helix default server is OmniSharp)
        omnisharp-roslyn
        # Java
        jdt-language-server
        # Python
        basedpyright
        ruff
        # Web / config formats
        vscode-langservers-extracted # html, css, json, eslint
        typescript-language-server
        yaml-language-server
        taplo # toml
        marksman # markdown
        # Shell
        bash-language-server
        shfmt
        shellcheck
      ];
    };
  };
}
