{ lib
, pkgs
, ...
}:
let
  krnix-installer = (pkgs.writeScriptBin "krnix-installer" (builtins.readFile ./krnix-installer.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in
{
  environment = {
    systemPackages = [
      krnix-installer
    ];
  };
}
