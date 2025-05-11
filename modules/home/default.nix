{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.zide;

  mkShellIntegrationOption = option:
    option
    // {
      default = false;
      example = true;
    };
in {
  options.programs.zide = {
    enable = mkEnableOption "zide";
    package = lib.mkPackageOption pkgs "zide" {};
    layoutDir = mkOption {
      type = types.str;
      default = "zide/layouts";
    };
    defaultLayout = mkOption {
      type = types.attrs;
      default = {};
    };

    enableBashIntegration = mkShellIntegrationOption (
      hm.shell.mkBashIntegrationOption {inherit config;}
    );

    enableFishIntegration = mkShellIntegrationOption (
      hm.shell.mkFishIntegrationOption {inherit config;}
    );

    enableZshIntegration = mkShellIntegrationOption (
      hm.shell.mkZshIntegrationOption {inherit config;}
    );
  };

  config = let
    shellIntegrationEnabled = (
      cfg.enableBashIntegration || cfg.enableZshIntegration || cfg.enableFishIntegration
    );
  in
    mkIf cfg.enable {
      home.packages = [cfg.package];

      home.sessionVariables = mkIf shellIntegrationEnabled {
        ZIDE_LAYOUT_DIR = "$HOME/.config/${cfg.layoutDir}";
      };

      xdg.configFile."${cfg.layoutDir}/default.kdl" =
        mkIf (cfg.defaultLayout != {})
        {
          text = lib.hm.generators.toKDL {} cfg.defaultLayout;
        };
    };
}
