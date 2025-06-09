{
  inputs,
  ...
}:
{
  system = "x86_64-linux";

  modules = [
    # Extra modules go here...
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
  ];

  # Userland home-manager overrides go here
  home = [
    ../../home/desktop.nix  # Or portable.nix for my lapto-centric settings

    {
      # Can toss in more overrides here, for example some hadrware-specific settings
      xresources.properties = {
        "Xft.dpi" = 256; # 2880x1920 over 13.5 screen (2.8K panel)
      };
    }
  ];


  # Root NixOS configuraiton lives here. Could have a separte configuration.nix file and import it here instead.
  # For example: root = import ./configuration.nix;
  root = { pkgs, ... }: {
    # All the normal configuration.nix stuff goes here...
    environment.systemPackages = with pkgs; [
      home-manager
      bat
      # ... whatever other apps we want installed in rootland
    ];

    networking.hostName = "example-host";

    system.stateVersion = "24.11";
  };
}
