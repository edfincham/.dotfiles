{
  description = "nix config";

  nixConfig = {
    extra-substituters = [
      "https://pi.cachix.org"
      "https://nix-community.cachix.org"
      "https://herdr.cachix.org"
    ];
    extra-trusted-public-keys = [
      "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    herdr-nix.url = "github:herdrdev/herdr-nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    herdr-nix,
    home-manager,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    unstable = nixpkgs-unstable.legacyPackages.${system};
    inherit (self) outputs;
  in {
    homeConfigurations = {
      ed = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home-manager/home/default.nix
        ];
      };
    };

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # pi.nix overlay exposes pkgs.pi-coding-agent (used in pi-instances.nix).
          { nixpkgs.overlays = [ inputs.pi.overlays.default ]; }
          ./nixos/configuration.nix
        ];
      };
    };
  };
}

