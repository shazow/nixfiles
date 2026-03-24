# shazowic-mollusk

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake github:shazow/nixfiles#shazowic-mollusk \
  --target-host nixos@192.168.2.162 \
  --generate-hardware-config nixos-generate-config hosts/shazowic-mollusk/hardware-configuration.nix
```
