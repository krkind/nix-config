{ config, desktop, hostname, hardwareConfig, herelinkSSID, inputs, lib, modulesPath, outputs, pkgs, stateVersion, username, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./_mixins/services/openssh.nix
    ./_mixins/services/avahi.nix
    ./_mixins/users/${username}
  ] ++ lib.optional (builtins.isString desktop) ./_mixins/desktop
  ++ lib.optional (hostname != "dvm") inputs.disko.nixosModules.disko
  ++ lib.optional (hostname != "dvm") ./${hardwareConfig};

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = lib.mkForce ''
    [org.gnome.shell]
    welcome-dialog-last-shown-version='9999999999'
    [org.gnome.desktop.session]
    idle-delay=0
    [org.gnome.settings-daemon.plugins.power]
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
    [org.gnome.desktop.screensaver]
    lock-enabled=false
    idle-activation-enabled=false
    lock-delay=0
    [org.gnome.desktop.lockdown]
    disable-lock-screen=true
  '';

  time.timeZone = "Europe/Stockholm";

  environment = {
    defaultPackages = with pkgs; lib.mkForce [
      vim
    ];
    systemPackages = with pkgs; [
      ffmpeg
      airostream_client
      gnumake
      pciutils
      psmisc
      unzip
      usbutils
      python3
      zsh
      hdparm
      socat
      rsync
      btop
      iperf3
      fastfetch
      kitty
      bash
    ];
    variables = {
      EDITOR = "vim";
      SYSTEMD_EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = true;
    package = pkgs.unstable.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  programs = {
    zsh = {
      enable = true;
      # Put everything we want to persist into /etc/nixos
      # The history is interesting to keep around for searchability
      histFile = "/etc/nixos/history";

      # Unset the default zsh options, in particular:
      # - No SHARE_HISTORY, because it makes the history file less readable
      # - No HIST_IGNORE_DUPS, so that the history file shows all commands
      # - Yes INC_APPEND_HISTORY, such that even when the VM is quit unexpectedly, we have the history
      setOptions = [ "INC_APPEND_HISTORY" ];
    };
    nix-ld.enable = true;
  };

  system.userActivationScripts.zshrc = "touch .zshrc";

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = stateVersion;
}
