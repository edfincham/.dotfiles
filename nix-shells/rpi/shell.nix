{ pkgs ? import <nixpkgs> {} }:

let
  rpi-imager-fixed = pkgs.rpi-imager.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      # Comment out the problematic qt_add_lupdate call
      sed -i 's/^qt_add_lupdate/#qt_add_lupdate/' CMakeLists.txt
    '';
  });
in
pkgs.mkShell {
  buildInputs = [ rpi-imager-fixed ];
}
