{
  description = "Zenful nix-darwin system flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Fixed-revision nixpkgs for surgically bumping individual packages ahead
    # of the main pin, without moving the whole system. Pinned to an explicit
    # commit (not a branch) so `nix flake update` does not drift it.
    # Currently supplies (see overlayNewerPackages below):
    #   - mill 1.1.8  (main pin is 1.1.2)
    nixpkgs-newer.url = "github:NixOS/nixpkgs/c7def046b9a883d46974757852106483d741586f";

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

      system = "aarch64-darwin";

      # Surgical package pins: pull specific attrs from `nixpkgs-newer` so they
      # land ahead of the main nixpkgs pin, with a blast radius of just these
      # packages. Applied to the system pkgs, which home-manager reuses via
      # useGlobalPkgs.
      overlayNewerPackages = _final: _prev: {
        inherit (inputs.nixpkgs-newer.legacyPackages.${system})
          mill
          ;
      };

      # Function for nix-darwin system configuration
      mkDarwinConfiguration =
        hostname: username:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            darwinModules = "${self}/modules/darwin";
          };
          modules = [
            ./hosts/${hostname}
            { nixpkgs.overlays = [ overlayNewerPackages ]; }
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
