{ config, desktop, lib, pkgs, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  # Only include desktop components if one is supplied.
  imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  users.users.kristian = {
    isNormalUser = true;
    initialPassword = "changeme";
    extraGroups = [
      "wheel"
      "dialout"
      "plugdev"
      "audio"
    ] # Enable ‘sudo’ for the user.
    ++ ifExists [
      "docker"
      "podman"
      "jellyfin"
      "wireshark"
      "libvirtd"
      "adbusers"
    ];
    packages = with pkgs; [
      firefox
      tree
    ];
    shell = pkgs.bash;
  };
}
