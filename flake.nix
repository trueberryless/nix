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
    system = "aarch64-darwin";
    username = "trueberryless";
    hostname = "tbl-macbook";

    specialArgs =
      inputs
      // {
        inherit username hostname;
      };
  in
  {
    # Apply darwin flake using:
    # $ darwin-rebuild switch --flake ~/.config/nix#tbl-macbook
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/host-users.nix
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/homebrew.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.extraSpecialArgs = {
            inherit username;
          };
          home-manager.users.${username} = import ./modules/home-manager.nix;
        }
      ];
    };
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
