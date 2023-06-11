## Setup

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


## Management

update: sync update-os update-env update-homemanager update-flatpak flatpak-clean-nvidia update-neovim

update-os:
	sudo nixos-rebuild switch

update-env:
	nix-env -u '*'

update-homemanager:
	home-manager switch --flake .

update-flatpak:
	flatpak update --appstream && flatpak update && flatpak uninstall --unused

update-neovim:
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

FLATPAK_LATEST_NVIDIA = $(shell flatpak list | grep "GL.nvidia" | cut -f2 | cut -d '.' -f5)
flatpak-clean-nvidia:
	flatpak list | grep org.freedesktop.Platform.GL32.nvidia- | cut -f2 | grep -v "$(FLATPAK_LATEST_NVIDIA)" | xargs -o flatpak uninstall

outdated: sync
	sudo nixos-rebuild dry-build --upgrade

sync:
	sudo nix-channel --update
	nix-channel --update

clean:
	sudo nix-collect-garbage --delete-older-than 7d
	home-manager expire-generations "-7 days"

wireguard: /etc/nixos/.wireguard.key
	wg genkey > "$@"
	chmod 400 "$@"

sup: # What's new?
	nix-shell -p nvd --run 'nvd diff $$(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)'
