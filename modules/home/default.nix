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

  defaultLayout = ''
    layout {
        tab name="zide" {
          compact_bar size=1
          floating_panes {
            zide_rename
          }
          pane split_direction="vertical" {
            filepicker size=60 name="picker"
            pane stacked=true {
              editor expanded=true
              lazygit
            }
            shell size=120 name="shell"
          }
          status_bar size=1
        }

        pane_template name="compact_bar" {
          borderless true
          plugin location="compact-bar"
        }

        pane_template name="editor" {
          command "$EDITOR"
        }

        pane_template name="filepicker" {
          command "zide-pick"
        }

        pane_template name="lazygit" start_suspended=true {
          command "lazygit"
        }

        pane_template name="shell" {
          command "$SHELL"
        }

        pane_template name="status_bar" {
          borderless true
          plugin location="status-bar"
        }

        pane_template name="zide_rename" command="zide-rename" close_on_exit=true

        new_tab_template {
          compact_bar size=1
          pane
          status_bar size=1
        }
      }
  '';

  btopLayout = ''
    layout {
      tab name="zide" {
        compact_bar size=1
        floating_panes {
          zide_rename
        }
        pane split_direction="vertical" {
          filepicker size=60 name="picker"
          pane stacked=true {
            editor expanded=true
            lazygit
          }
          shell size=120 name="shell"
        }
        status_bar size=1
      }

      tab name="sys" {
        compact_bar size=1
        pane split_direction="vertical" {
          pane split_direction="horizontal" {
            cpu name="cpu"
            net name="net"
            mem name="mem"
          }
          pane split_direction="horizontal" {
            proc name="proc"
            systemd name="systemd" size=60
          }
        }
        status_bar size=1
      }

      pane_template name="cpu" {
        command "btop"
        args "-c" "$HOME/.config/btop/cpu.conf" "-u" "100"
      }

      pane_template name="net" {
        command "btop"
        args "-c" "$HOME/.config/btop/net.conf" "-u" "2000"
      }

      pane_template name="mem" {
        command "btop"
        args "-c" "$HOME/.config/btop/mem.conf" "-u" "2000"
      }

      pane_template name="proc" {
        command "btop"
        args "-c" "$HOME/.config/btop/proc.conf"
      }

      pane_template name="systemd" {
        command "watch"
        args "-t" "-c" "systemctl" "--user" "list-units" "--type" "service" "--state" "running,failed"
      }

      pane_template name="compact_bar" {
        borderless true
        plugin location="compact-bar"
      }

      pane_template name="editor" {
        command "$EDITOR"
      }

      pane_template name="filepicker" {
        command "zide-pick"
      }

      pane_template name="lazygit" start_suspended=true {
        command "lazygit"
      }

      pane_template name="shell" {
        command "$SHELL"
      }

      pane_template name="status_bar" {
        borderless true
        plugin location="status-bar"
      }

      pane_template name="zide_rename" command="zide-rename" close_on_exit=true

      new_tab_template {
        compact_bar size=1
        pane
        status_bar size=1
      }
    }
  '';
in {
  options.programs.zide = {
    enable = mkEnableOption "zide";
    enableBtop = mkEnableOption "btop";
    enableBashIntegration = mkShellIntegrationOption (
      hm.shell.mkBashIntegrationOption {inherit config;}
    );

    enableFishIntegration = mkShellIntegrationOption (
      hm.shell.mkFishIntegrationOption {inherit config;}
    );

    enableYazi = mkEnableOption "yazi";

    enableZshIntegration = mkShellIntegrationOption (
      hm.shell.mkZshIntegrationOption {inherit config;}
    );

    package = lib.mkPackageOption pkgs "zide" {};

    layoutDir = mkOption {
      type = types.str;
      default = "zide/layouts";
    };

    layout = mkOption {
      type = kdlConfigType;
      default = defaultLayout;
      description = ''
        Defines your layouts/default.kdl. Can either be a path pointing to layout.kdl, a multi-line string or an attributes set representing a KDL configuration.
      '';
    };

    autoLayoutPackage = lib.mkPackageOption pkgs "yaziPlugins.auto-format" {};
  };

  config = let
    layout =
      if cfg.enableBtop
      then btopLayout
      else defaultLayout;

    shellIntegrationEnabled = (
      cfg.enableBashIntegration || cfg.enableZshIntegration || cfg.enableFishIntegration
    );
  in
    mkMerge [
      (mkIf (cfg.enable) {
        home.packages = [pkgs.lazygit pkgs.zellij cfg.package];
        home.sessionVariables = mkIf shellIntegrationEnabled {
          ZIDE_LAYOUT_DIR = "$HOME/.config/${cfg.layoutDir}";
        };

        programs.zellij.enable = true;

        xdg.configFile."${cfg.layoutDir}/default.kdl" =
          if builtins.isPath layout
          then {source = layout;}
          else {
            text =
              if builtins.isAttrs layout
              then lib.hm.generators.toKDL {} layout
              else layout;
          };
      })
      (mkIf (cfg.enableBtop) {
        home.packages = [pkgs.btop];
        xdg.configFile."btop/cpu.conf" = {
          text = ''
            color_theme = "TTY"
            theme_background = False
            truecolor = True
            shown_boxes = "cpu"
          '';
        };

        xdg.configFile."btop/mem.conf" = {
          text = ''
            color_theme = "TTY"
            theme_background = False
            truecolor = True
            shown_boxes = "mem"
          '';
        };

        xdg.configFile."btop/net.conf" = {
          text = ''
            color_theme = "TTY"
            theme_background = False
            truecolor = True
            shown_boxes = "net"
          '';
        };

        xdg.configFile."btop/proc.conf" = {
          text = ''
            color_theme = "TTY"
            theme_background = False
            truecolor = True
            shown_boxes = "proc"
          '';
        };
      })
      (mkIf (cfg.enableYazi) {
        home.packages = [pkgs.yazi];
        programs.yazi = {
          enable = true;
          enableBashIntegration = cfg.enableBashIntegration;
          enableFishIntegration = cfg.enableFishIntegration;
          enableZshIntegration = cfg.enableZshIntegration;
          plugins = {
            auto-layout = cfg.autoLayoutPackage;
          };
        };
      })
    ];
}
