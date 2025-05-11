{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "zide";
  version = "3.2.0";
  src = ./..;
  installPhase = ''
    mkdir -p $out/{bin,layouts,lf,yazi}
    cp -a $src/bin $out
    cp -a $src/layouts $out
    cp -a $src/lf $out
    cp -a $src/yazi $out
    chmod -R +x $out/bin/
    chmod -R +x $out/lf/
    chmod -R +x $out/yazi/
  '';
}
