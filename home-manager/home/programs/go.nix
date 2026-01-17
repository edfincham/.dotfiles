{ pkgs, ... }: {
  enable = true;

  package = pkgs.go;
  goPath = "go";
  goBin = ".local/bin.go";
  packages = { };
}
