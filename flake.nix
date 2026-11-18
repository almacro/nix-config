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

    #  Let linux laptop follow NixOS
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager-nixos = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };
  };

  outputs =
    {
      self,
      darwin,
      home-manager,
      nixpkgs,
      nixpkgs-nixos,
      home-manager-nixos,
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

      # Function for a NixOS configuration. Parameterised by `system` and the
      # `nixpkgs` / `homeManager` inputs so ONE helper serves both the unstable
      # aarch64-linux vfkit VM (helper defaults = the Mac inputs) and the stable
      # x86_64-linux blackfish laptop (passes nixpkgs-nixos / home-manager-nixos).
      # Reuses the shared home-manager `common` module (darwin-only bits are
      # isDarwin guarded). NOTE: building needs a builder for `system` — easiest
      # is to run `nixos-rebuild switch --flake .#<host>` from INSIDE the target.
      mkNixosConfiguration =
        {
          system,
          hostname,
          username,
          nixpkgs ? inputs.nixpkgs,
          homeManager ? home-manager,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
          };
          modules = [
            ./hosts/${hostname}
            homeManager.nixosModules.home-manager
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

      nixosConfigurations = {
        # Apple Silicon NixOS guest under vfkit — tracks unstable (helper
        # defaults = the Mac inputs). Output name matches the hostname so
        # `nixos-rebuild --flake .` works in-guest with no #name.
        "nixvm" = mkNixosConfiguration {
          system = "aarch64-linux";
          hostname = "nixvm";
          username = "almacro";
        };

        # x86_64 Linux laptop on stable NixOS (nixos-26.05).
        "blackfish" = mkNixosConfiguration {
          system = "x86_64-linux";
          hostname = "blackfish";
          username = "almacro";
          nixpkgs = nixpkgs-nixos;
          homeManager = home-manager-nixos;
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
