{ lib, pkgs, herelinkSSID, ... }:
{
  imports = [
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  environment.etc."NetworkManager/system-connections/herelink.nmconnection".text = ''
    [connection]
    id=herelink
    type=wifi
    autoconnect-priority=10

    [wifi]
    ssid=${herelinkSSID}

    [wifi-security]
    auth-alg=open
    key-mgmt=wpa-psk
    psk=@airolit!!

    [ipv4]
    address1=192.168.43.3/24
    method=manual
    routes=192.168.144.0/24,192.168.43.1
  '';
  environment.etc."NetworkManager/system-connections/herelink.nmconnection".mode = "0400";

  networking.firewall.enable = true;
  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -o enp0s13f0u1 -j MASQUERADE
  '';

  systemd.user.services.airostream_client = {
    enable = true;
    serviceConfig.PassEnvironment = "DISPLAY";
    description = "Airostream Client Service";
    wantedBy = [ "default.target" ];
    after = [ "network.target" "graphical-session.target" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.ffmpeg}/bin/ffplay rtsp://192.168.43.2:8554/airostream -fflags nobuffer -flags low_delay -framedrop -fs -autoexit";
      Environment = "DISPLAY=:0";
      Restart = "always";
      RestartSec = 1;
    };
  };
}
