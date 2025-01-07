{
  description = "Krkind NixOS Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # You can access packages and modules from different nixpkgs revs at the
    # same time. See 'unstable-packages' overlay in 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

  };
  outputs =
    { self
    , nix-formatter-pack
    , home-manager
    , nixpkgs
    , nixos-hardware
    , nixos-generators
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "24.11";

      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = nixpkgs.legacyPackages;
    in
    {
      inherit lib;
      # nix fmt
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      # The NixOS configurations
      nixosConfigurations =
        let
          iso_params = {
            services.displayManager.autoLogin.user = lib.mkForce "kristian";
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
          };
        in
        {
          #########################################
          #
          # Home
          #
          #########################################

          kristian@nix-home = lib.nixosSystem {

            modules = [
              ./nixos
              home-manager.nixosModules.home-manager
              {
                home-manager.users.kristian = {
                  imports = [
                    ./home-manager
                  ];
                };
                home-manager.extraSpecialArgs = {
                  inherit inputs outputs stateVersion;
                  hostname = "nix-home";
                  platform = "x86_64-linux"
                  username = "kristian";
                };
              }
            ];

            specialArgs = {
              inherit inputs outputs stateVersion;
              hostname = "nix-home";
              username = "kristian";
              desktop = "gnome";
            };

          };

          #########################################
          #
          # WORK
          #
          #########################################

          kristian@nix-work = lib.nixosSystem {

            modules = [
              ./nixos
              home-manager.nixosModules.home-manager
              {
                home-manager.users.kristian = {
                  imports = [
                    ./home-manager
                  ];
                };
                home-manager.extraSpecialArgs = {
                  inherit inputs outputs stateVersion;
                  hostname = "nix-work";
                  platform = "x86_64-linux"
                  username = "kristian";
                };
              }
            ];

            specialArgs = {
              inherit inputs outputs stateVersion;
              hostname = "nix-work";
              username = "kristian";
              desktop = "gnome";
            };

          };

          # Build using: nix build .#nixosConfigurations.krnix-installer.config.system.build.isoImage 
          # Handy debug tip: nix eval .#nixosConfigurations.krnix-installer.config.isoImage.squashfsCompression
          iso-installer = lib.nixosSystem {
            modules = [
              ./nixos
              (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix")
              iso_params
              home-manager.nixosModules.home-manager
              {
                home-manager.users.kristian = {
                  imports = [
                    ./home-manager
                  ];
                };
                home-manager.extraSpecialArgs = {
                  inherit inputs outputs stateVersion;
                  username = "kristian";
                };
              }
            ];
            specialArgs = {
              inherit inputs outputs stateVersion;
              hostname = "krkind-nix-installer";
              username = "kristian";
              desktop = "gnome";
            };
          };
        };
    };
}
