{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "zide";
  version = "3.2.0";
  src = ./..;
  installPhase = ''
    mkdir -p $out/{bin,layouts,lf,yazi}
    cp -ar $src/bin/ $out/bin/
    cp -ar $src/layouts/ $out/layouts/
    cp -ar $src/lf/ $out/lf/
    cp -ar $src/yazi/ $out/yazi/
    chmod -R +x $out/bin/
  '';
}
