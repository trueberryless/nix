{
  description = "Felix's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager }:
  let
    system = "aarch64-darwin";
    username = "trueberryless";
    hostname = "shai-hulud";

    specialArgs =
      inputs
      // {
        inherit username hostname system;
      };
  in
  {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/apps.nix
        ./modules/fonts.nix
        ./modules/homebrew.nix
        ./modules/host-users.nix
        ./modules/launchd.nix
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/wallpapers.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit username hostname;
          };
          home-manager.users.${username} = import ./modules/home-manager.nix;
        }
      ];
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
