{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "zide";
  version = "3.2.0";
  src = ./..;
  installPhase = ''
    mkdir -p $out/{bin,layouts}
    cp -a $src/bin $out
    cp -a $src/layouts $out
    chmod -R +x $out/bin/
  '';
}
