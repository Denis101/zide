{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "zide";
  version = "3.2.0";

  src = pkgs.fetchFromGitHub {
    owner = "denis101";
    repo = "zide";
    rev = "main";
    sha256 = "sha256-Ten0Jme1wVDsUhRY/ggPY1fKwYRw0FiQWSQqVij3nHI";
  };

  installPhase = ''
    mkdir -p $out/{bin,layouts,lf,yazi}
    cp -r $src/bin/* $out/bin/
    cp -r $src/layouts/* $out/layouts/
    cp -r $src/lf/* $out/lf/
    cp -r $src/yazi/* $out/yazi/
    chmod -R +x $out/bin/
  '';
}
