# Fetch latest emojis and compile thme into a one-line-per-emoji text file with fzf searchable descriptions
# Example usage:
#   cat ${emojis}/emoji-list.txt | fuzzel --match-mode fzf --dmenu | cut -f1 | xargs wtype
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "emoji-list";
  version = "15.1.2";

  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/iamcal/emoji-data/refs/tags/v${version}/emoji.json";
    sha256 = "0p9dwfjxnnr7yqb5998dk8dv51d5m0870gvvfjs8gyxv529921dj";
  };

  buildInputs = [ pkgs.python3 ];

  unpackPhase = ''
    cp $src emoji.json
    '';


  installPhase = let
    parserScript = pkgs.writeText "parser.py" # python
      ''
      import json, sys

      for emoji in json.load(sys.stdin):
        unified_code = emoji.get('unified')
        if not unified_code:
          continue

        # 1. Split the code by '-': e.g., "1F44D-1F3FB" -> ["1F44D", "1F3FB"]
        # 2. Convert each hex part to an integer: -> [128077, 127995]
        # 3. Convert integer codepoints to characters: -> "👍🏻"
        char = "".join(chr(int(code, 16)) for code in unified_code.split('-'))

        # Get the name and join the short_names into a single string
        name = emoji.get('name')
        short_names = ", ".join(emoji.get('short_names', []))

        # Print the final result
        print(f"{char}\t{name}\t{short_names}")
      '';
  in ''
    runHook preInstall
    mkdir -p $out
    echo $src
    python ${parserScript} < $src > $out/emoji-list.txt
    runHook postInstall
  '';

  dontFixup = true;
}
