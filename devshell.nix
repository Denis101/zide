{pkgs}:
pkgs.mkShell {
  packages = with pkgs; [
    alejandra
    editorconfig-checker
    pre-commit
    shellcheck
  ];
}
