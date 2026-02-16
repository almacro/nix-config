{
  description = "Zenful nix-darwin system flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      darwin,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      # Define user configurations
      users = {
        "alfred.thompson" = {
          inherit (users.almacro)
            email
            fullName
            gitKey
            ;
          name = "alfred.thompson";
        };
        "almacro" = {
          email = "alm4x1mu5@gmail.com";
          fullName = "Alfred Thompson";
          gitKey = "CHANGEME"; # TODO: set GPG key for commit signing
          name = "almacro";
        };
      };

      # Function for nix-darwin system configuration
      mkDarwinConfiguration =
        hostname: username:
        darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            darwinModules = "${self}/modules/darwin";
          };
          modules = [
            ./hosts/${hostname}
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs outputs;
                userConfig = users.${username};
                nhModules = "${self}/modules/home-manager";
              };
              home-manager.users.${username} = import ./home/${username}/${hostname};
            }
          ];
        };

    in
    {
      darwinConfigurations = {
        "Blackbook" = mkDarwinConfiguration "Blackbook" "almacro";
        "Stellarbook" = mkDarwinConfiguration "Stellarbook" "almacro";
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
