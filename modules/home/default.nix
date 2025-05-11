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

  kdlConfigType = with types; nullOr (oneOf [path kdlType lines]);
  kdlType = with types; let
    valueType = nullOr (oneOf [bool int float str path (attrsOf valueType) (listOf valueType)]);
  in
    valueType;
in {
  options.programs.zide = {
    enable = mkEnableOption "zide";
    package = lib.mkPackageOption pkgs "zide" {};
    layoutDir = mkOption {
      type = types.str;
      default = "zide/layouts";
    };
    defaultLayout = mkOption {
      type = kdlConfigType;
      default = {};
      description = ''
        Defines your layouts/default.kdl. Can either be a path pointing to config.kdl, a multi-line string or an attributes set representing a KDL configuration.
      '';
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
