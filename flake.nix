{
  inputs = {
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    preservation.url = "github:nix-community/preservation";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      sharedModules = [
        inputs.disko.nixosModules.disko
        inputs.preservation.nixosModules.default
	inputs.minegrub-theme.nixosModules.default
        ./configuration.nix
        ./preservation.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.marco = import ./home.nix;
          home-manager.backupFileExtension = "hm-backup";
        }
      ];
    in
    {
      nixosConfigurations = {
        leto-ii = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [
            ./hosts/leto-ii/hardware-configuration.nix
            ./hosts/leto-ii/disko.nix
            {
              networking.hostName = "leto-ii";
            }
          ];
        };
        ghanima = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [
            ./hosts/ghanima/hardware-configuration.nix
            ./hosts/ghanima/disko.nix
            {
              networking.hostName = "ghanima";
            }
          ];
        };
      };
    };
}
