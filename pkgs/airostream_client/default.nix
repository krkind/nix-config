{ lib
, pkgs
, stdenv
, makeWrapper
, coreutils
, ffmpeg
, python3
, vlc
}:

with lib;

stdenv.mkDerivation {
  name = "airostream_client";
  version = "1.0";
  src = ./.;

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [
    (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
    ]))
  ];

  installPhase = ''
    install -Dm755 ${./run.py} $out/bin/airostream_client
    install -Dm644 ${./waiting_for_drone_video.mp4} $out/share/airostream_client/waiting_for_drone_video.mp4
    wrapProgram $out/bin/airostream_client --set PATH \
          "${
            makeBinPath [
              vlc
              ffmpeg
            ]
          }" --set WAITING_VIDEO_PATH $out/share/airostream_client/waiting_for_drone_video.mp4
  '';

  meta = {
    description = "The airostream client";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
