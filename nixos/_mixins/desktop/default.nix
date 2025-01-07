{ desktop, lib, pkgs, ... }: {
  imports = [
  ]
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

  services.xserver.enable = true;
  services.libinput.enable = true;

  services.xserver = {
    autoRepeatDelay = 250;
    autoRepeatInterval = 50;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    vlc
    gnomeExtensions.no-overview
  ];
}
