{
  outputs = { self }: {

    templates.nixos-device = {
      path = ./nixos-device;
      description = "Template for a NixOS device using github:shazow/nixfiles";
      welcomeText = ''
        # shazowic nixos device

        ## Replace
        - [ ] hashedPassword in flake.nix
      '';
    };

    templates.default = self.templates.nixos-device;
  };
}
