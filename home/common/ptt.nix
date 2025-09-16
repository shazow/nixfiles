# Don't ask...
{ pkgs }:

let
  sounds = pkgs.stdenv.mkDerivation {
    name = "nixfiles-sounds";
    src = ../../assets/sounds;
    installPhase = ''
      mkdir -p $out
      cp -r ./* $out/
    '';
  };
in
{
  "push-to-talk" = pkgs.writeScript "push-to-talk" ''
    case $1 in
        on)
            pamixer --default-source -u
            pw-cat -p "${sounds}/ptt-activate.mp3"
        ;;
        off)
            pamixer --default-source -m
            pw-cat -p "${sounds}/ptt-deactivate.mp3"
        ;;
    esac
  '';
}
