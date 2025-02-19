{ pkgs, ... }: {
  enable = true;
  enableSshSupport = false;
  enableExtraSocket = true;
  defaultCacheTtl = 3600;
}
