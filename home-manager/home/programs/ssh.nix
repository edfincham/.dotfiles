{ pkgs, ... }: {
  enable = true;
  matchBlocks."*" = {
    identityFile = "~/.ssh/id_ed25519";
  };
  addKeysToAgent = "yes";
}
