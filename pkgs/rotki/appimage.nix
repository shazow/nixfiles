# Based on https://github.com/FlorianFranzen/nixrc/blob/master/pkgs/rotki.nix
{ lib, stdenv, fetchurl, appimageTools, undmg, libsecret, libxshmfence }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "rotki";
  version = "v1.31.2";
  name = "${pname}-${version}";

  suffix = {
    x86_64-linux = "linux_x86_64-v${version}.AppImage";
    x86_64-darwin = "darwin_x64-v${version}.dmg";
  }.${system} or throwSystem;

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}-${suffix}";
    sha256 = {
      x86_64-linux = "Vbe4aHchja6A2O2zWOvJREGop3pFl0Hl/iDqee+/OfM=";
      x86_64-darwin = lib.fakeSha256;
    }.${system} or throwSystem;
  };

  appimageContents = appimageTools.extract {
    inherit name src;
  };

  meta = with lib; {
    description = "A portfolio tracking, analytics, accounting and tax reporting application that protects your privacy.";
    homepage = "https://rotki.com";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };

  linux = appimageTools.wrapType2 rec {
    inherit name src meta;

    extraPkgs = pkgs: with pkgs; [ libsecret libxshmfence ];

    extraInstallCommands = ''
      mv $out/bin/{${name},${pname}}
      install -Dm644 ${appimageContents}/rotki.desktop -t $out/share/applications
      install -Dm644 ${appimageContents}/rotki.png -t $out/share/icons/hicolor/256x256/apps
      substituteInPlace $out/share/applications/rotki.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ undmg ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
