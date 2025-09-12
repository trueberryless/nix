{
  description = "Felix's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager }:
  let
    username = "trueberryless";
    system = "aarch64-darwin";
    hostname = "tbl-macbook";

    specialArgs =
      inputs
      // {
        inherit username hostname;
      };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#tbl-macbook
    darwinConfigurations."tbl-macbook" = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/host-users.nix
        home-manager.darwinModules.home-manager  {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.users.${username} = ./modules/home-manager.nix;
        }
        ./modules/apps.nix
        ./modules/homebrew.nix
      ];
    };
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
