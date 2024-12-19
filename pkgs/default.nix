{ pkgs ? import <nixpkgs> { } }: rec {

  # Packages with an actual source

  # Personal scripts
  airostream_client = pkgs.callPackage ./airostream_client { };
}
