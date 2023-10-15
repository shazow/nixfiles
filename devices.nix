{ inputs }:
{
  "shazowic-corvus" = {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen

      ./shazowic-corvus.nix
    ];
    home = [
      ./home/portable.nix
    ];
  };

  "shazowic-beast" = {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.common-cpu-amd

      ./shazowic-beast.nix
    ];
    home = [
      ./home/desktop.nix
    ];
  };

  "shazowic-ent" = {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-gpu-amd

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
