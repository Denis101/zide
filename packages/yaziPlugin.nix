{pkgs, ...}:
# Not sure how to use this directly atm:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ya/yazi/plugins/default.nix
let
  updateScript = ./update.py;
in
  pkgs.stdenvNoCC.mkDerivation {
    pname = "auto-layout.yazi";
    version = "3.2.0";
    src = ./../yazi/plugins/auto-layout.yazi;

    installPhase = ''
      runHook preInstall
      cp -r . $out
      runHook postInstall
    '';

    passthru = {
      updateScript = {
        command = pkgs.writeShellScript "update-auto-layout" ''
          export PLUGIN_NAME="auto-layout"
          export PLUGIN_PNAME="$auto-layout.yazi"
          exec ${updateScript}
        '';
        supportedFeatures = ["commit"];
      };
    };
  }
