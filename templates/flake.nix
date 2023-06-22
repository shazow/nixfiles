{
  outputs = { self }: {

    templates.nixos-device = {
      path = ./nixos-device;
      description = "Template for a NixOS device using github:shazow/nixfiles";
      welcomeText = ''
        # shazowic nixos device

        ## Checklist
        - [ ] Update input path to nixfiles
        - [ ] Replace hashedPassword and other sensitive data in flake.nix
        - [ ] Confirm desirable chmod permissions on flake (read-only by root?)
      '';
    };

    templates.default = self.templates.nixos-device;
  };
}
