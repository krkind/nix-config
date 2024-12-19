{ lib, pkgs, herelinkSSID, ... }:
{
  imports = [
  ];

  networking.firewall.enable = false;

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
    address1=192.168.43.2/24
    gateway=192.168.43.3
    dns=8.8.8.8
    method=manual
    routes=192.168.144.0/24,192.168.43.1
  '';
  environment.etc."NetworkManager/system-connections/herelink.nmconnection".mode = "0400";

  services.mediamtx = {
    enable = true;
    settings = {
      protocols = [ "tcp" ];
      paths = {
        airostream = {
          source = "rtsp://192.168.144.111:8554/live0";
          sourceOnDemand = true;
        };
      };
    };
  };

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
