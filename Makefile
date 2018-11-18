HOST ?= example

config: password configuration.nix

configuration.nix: hosts/${HOST}.nix
	@echo "Generating configuration: HOST=${HOST}"
	ln -s "$<" "$@"

password: .hashedPassword.nix

.hashedPassword.nix:
	mkpasswd -m sha-512 > "$@"
