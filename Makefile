HOST ?= example
KEYFILE ?= cryptroot.key
KEYSIZE ?= 4096

config: password configuration.nix

configuration.nix: hosts/${HOST}.nix
	@echo "Generating configuration: HOST=${HOST}"
	ln -s "$<" "$@"

password: .hashedPassword.nix

.hashedPassword.nix:
	mkpasswd -m sha-512 > "$@"

${KEYFILE}:
	dd if=/dev/random of="$@" bs=1 count=${KEYSIZE}
	@echo "Add keyfile to encrypted volume: cryptsetup luksAddKey $$DEVICE ${KEYFILE}"

initrd.keys.gz: ${KEYFILE}
	find $^ | cpio --quiet -H newc -o | gzip -9 -n > "$@"
