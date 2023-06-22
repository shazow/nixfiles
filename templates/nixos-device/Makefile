all: update switch

update:
	nix flake update

switch:
	nixos-rebuild switch --flake .
