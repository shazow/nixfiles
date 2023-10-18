all: update

## Management

update: sync update-os update-env update-homemanager update-flatpak

update-os:
	sudo -i sh -c 'cd nixfiles && git pull'
	sudo -i sh -c 'cd nixos && make'

update-env:
	nix-env -u '*'

update-homemanager:
	home-manager switch --flake .

update-flatpak:
	flatpak update --appstream && flatpak update && flatpak uninstall --unused

outdated: sync
	# TODO: sudo nixos-rebuild dry-build --upgrade
	echo "Not implemented for flake"

sync:
	nix flake update

clean:
	sudo nix-collect-garbage --delete-older-than 7d
	home-manager expire-generations "-7 days"

wireguard: /etc/nixos/.wireguard.key
	wg genkey > "$@"
	chmod 400 "$@"

sup: # What's new?
	nix-shell -p nvd --run 'nvd diff $$(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)'


## Setup
# Note: This is for old pre-flake stuff

HOST ?= example
KEYFILE ?= cryptroot.key
KEYSIZE ?= 4096

config: password configuration.nix

configuration.nix: hosts/${HOST}.nix
	@echo "Generating configuration: HOST=${HOST}"
	ln -s "$<" "$@"

password: .hashedPassword.nix

.hashedPassword.nix:
	echo "\"$$(mkpasswd -m sha-512)\"" > "$@"
	chmod 400 "$@"

${KEYFILE}:
	dd if=/dev/urandom of="$@" bs=1 count=${KEYSIZE}
	@echo "Add keyfile to encrypted volume: cryptsetup luksAddKey $$DEVICE ${KEYFILE}"

initrd.keys.gz: ${KEYFILE}
	find $^ | cpio --quiet -H newc -o | gzip -9 -n > "$@"
	chmod 400 "$@"


