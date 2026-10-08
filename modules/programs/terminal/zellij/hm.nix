{
  config,
  lib,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.terminal.zellij.enable {
    programs.zellij = {
      enable = true;
      # Don't hijack every terminal; run `zellij` or `ide` when you want it.
      enableBashIntegration = false;

      settings = {
        # Start "locked": every key goes to Helix/yazi/lazygit untouched, so
        # nothing clashes with Ctrl+o / Ctrl+s / Ctrl+b etc. in Helix.
        # Ctrl+g unlocks Zellij's own modal keys when you need them.
        default_mode = "locked";
        show_startup_tips = false;
        show_release_notes = false;
        pane_frames = true;
        copy_on_select = true;
      };

      # A small set of Alt-bindings that work even while locked
      # (Helix has nothing on these keys).
      extraConfig = ''
        keybinds {
            locked {
                bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
                bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
                bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                bind "Alt k" "Alt Up" { MoveFocus "Up"; }
                bind "Alt f" { ToggleFloatingPanes; }
                bind "Alt n" { NewPane; }
                bind "Alt t" { NewTab; }
                bind "Alt w" { CloseFocus; }
                bind "Alt z" { ToggleFocusFullscreen; }
                bind "Alt =" "Alt +" { Resize "Increase"; }
                bind "Alt -" { Resize "Decrease"; }
                bind "Alt g" { Run "lazygit" { floating true; close_on_exit true; name "lazygit"; }; }
                bind "Alt y" { Run "yazi" { floating true; close_on_exit true; name "files"; }; }
            }
        }
      '';
    };
  };
}
