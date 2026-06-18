# shazowic-urchin

Topton Intel Gold 8505 Mini PC with DDR5 memory, NVMe storage, four Intel i226-V 2.5G ports, and two 10G SFP+ ports.

```bash
mkdir -p secrets/tmp
mkpasswd -m sha-512 > secrets/tmp/initial-password

nix run github:nix-community/nixos-anywhere -- \
  --flake "github:shazow/nixfiles#shazowic-urchin" \
  --target-host nixos@192.168.2.203 \
  --extra-files ./secrets \
  --generate-hardware-config nixos-generate-config hosts/shazowic-urchin/hardware.nix

rm -rf ./secrets
```
