HOSTNAME = $(shell hostname)
USER = $(shell whoami)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

ifndef USER
 $(error User unknown)
endif

help:
	@echo "Available targets:"
	@echo "  os         - Rebuilds the NixOS configuration."
	@echo "  iso        - Builds an ISO image of the NixOS configuration."

os:
	sudo nixos-rebuild switch --flake ~/dev/nix-config/#${HOSTNAME}
iso:
	nix build .#nixosConfigurations.krkind-nix-installer.config.system.build.isoImage
