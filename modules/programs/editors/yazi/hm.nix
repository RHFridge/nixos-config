{
  config,
  lib,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.editors.yazi.enable {
    stylix.targets.yazi.enable = true;

    programs.yazi = {
      enable = true;
      # `y` = yazi that cd's your shell to wherever you quit it
      enableBashIntegration = true;
      shellWrapperName = "y";
      settings = {
        mgr = {
          show_hidden = false; # toggle with `.`
          sort_dir_first = true;
          linemode = "size";
        };
      };
      keymap.mgr.prepend_keymap = [
        {
          on = ["g" "i"];
          run = "shell 'lazygit' --block";
          desc = "Open lazygit here";
        }
        {
          on = ["e"];
          run = "shell 'hx .' --block";
          desc = "Open Helix in this directory";
        }
      ];
    };
  };
}
