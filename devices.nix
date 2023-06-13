{
  "shazowic-corvus" = {
    system = "x86_64-linux";
    modules = [
      ./shazowic-corvus.nix
    ];
    home = [
      ./home/portable.nix
    ];
  };

  "shazowic-beast" = {
    system = "x86_64-linux";
    modules = [
      ./shazowic-beast.nix
    ];
    home = [
      ./home/desktop.nix
    ];
  };

  "shazowic-ghost" = {
    system = "x86_64-linux";
    modules = [
      ./shazowic-ghost.nix
    ];
    home = [];
  };
}
