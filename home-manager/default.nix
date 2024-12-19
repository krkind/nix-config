{ config, desktop, lib, outputs, pkgs, stateVersion, username, ... }:
with lib.hm.gvariant;
let
  inherit (pkgs.stdenv) isDarwin;
  wallpaperPath = ../img/bg.jpg;
in
{
  imports = [ ];

  home = {
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];
    inherit stateVersion;
    inherit username;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2941
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.unstable.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  home.file.".background-image" = {
    source = wallpaperPath;
    target = "${config.home.homeDirectory}/wallpaper";
  };

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "no-overview@fthx"
      ];
    };
    "org/gnome/desktop/background" = {
      #color-shading-type = lib.hm.gvariant.mkString "solid";
      picture-options = lib.hm.gvariant.mkString "zoom";
      picture-uri = lib.hm.gvariant.mkString "file:///home/airolit/wallpaper";
      picture-uri-dark = lib.hm.gvariant.mkString "file:///home/airolit/wapllpaper"; # Use the same for dark mode
      primary-color = lib.hm.gvariant.mkString "#000000";
      secondary-color = lib.hm.gvariant.mkString "#000000";
    };
  };
}
