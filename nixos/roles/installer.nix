{ lib, pkgs, ... }:
{
  imports = [
    ../../pkgs/krnix-installer
  ];

  environment.etc."NetworkManager/system-connections/Airolit.nmconnection".text = ''
    [connection]
    id=Airolit
    type=wifi

    [wifi]
    ssid=Airolit

    [wifi-security]
    auth-alg=open
    key-mgmt=wpa-psk
    psk=@A1r0l1t_!?
  '';
  environment.etc."NetworkManager/system-connections/Airolit.nmconnection".mode = "0400";

  systemd.user.services.fastfetch = {
    serviceConfig.PassEnvironment = "DISPLAY";
    description = "Start terminal with fastfetch";
    enable = true;
    after = [ "graphical.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.kitty}/bin/kitty --start-as fullscreen -e ${pkgs.bash}/bin/bash -c '${pkgs.fastfetch}/bin/fastfetch; read -n 1'";
      Restart = "always";
      Environment = "DISPLAY=:0";
    };
  };
}
