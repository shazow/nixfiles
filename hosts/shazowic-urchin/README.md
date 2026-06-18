# shazowic-urchin

Topton Intel Gold 8505 Mini PC with DDR5 memory, NVMe storage, four Intel i226-V 2.5G ports, and two 10G SFP+ ports.

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .
  --target-host nixos@192.168.2.203 \
  --generate-hardware-config nixos-generate-config hosts/shazowic-urchin/hardware.nix
```
