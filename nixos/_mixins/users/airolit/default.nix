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

  users.users.airolit = {
    isNormalUser = true;
    initialPassword = "@airolit!!";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPV/ktL05mbhMNHis8zdpYUk76GcnVWXFrxEc8Hvtxhq ripxorip"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYQzn/cyH2sWgQy4eEujslOQiumIL5oPtGTNYJvDf4o ripxorip@ripxowork" # The airolit key
    ];
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
