{
  config,
  lib,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.editors.lazygit.enable {
    programs.lazygit = {
      enable = true;
      # `lg` = lazygit that cd's you into whatever repo/worktree you leave it in
      enableBashIntegration = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
          showBottomLine = false;
        };
        promptToReturnFromSubprocess = false;
      };
    };
  };
}
