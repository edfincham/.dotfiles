{ pkgs, ... }: {
  enable = true;
  enableSshSupport = false;
  enableExtraSocket = true;
  defaultCacheTtl = 3600;
  pinentryPackage = pkgs.pinentry-gnome3;
}
