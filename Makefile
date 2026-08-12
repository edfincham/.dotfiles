.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Setup:"
	@echo "  deps                  Install Nix dependencies"
	@echo "  init                  Initialize dotfile symlinks"
	@echo ""
	@echo "Daily commands:"
	@echo "  hm-rebuild            Rebuild home manager configuration"
	@echo "  nixos-rebuild         Rebuild NixOS configuration"
	@echo "  sync                  Sync dotfiles with git repository"
	@echo ""
	@echo "Maintenance:"
	@echo "  update                Update both nixpkgs and home-manager"
	@echo "  clean                 Run garbage collection"
	@echo "  check                 Check nix flake for errors"
	@echo "  reboot                Update and reboot NixOS"

.PHONY: deps
deps:
	@echo "Installing dependencies.."
	@command nix --version >/dev/null 2>&1 || echo "Install Nix: curl -L https://nixos.org/nix/install | sh"

.PHONY: init
CONFIGS := i3 nvim
init:
	@echo "Initializing dotfile symlinks... ${CONFIGS}"
	@for c in $(CONFIGS); do \
		[ -d ~/.config/$$c ] && rm -rf ~/.config/$$c || true; \
		ln -sf $(PWD)/home-manager/.config/$$c ~/.config/$$c; \
	done

.PHONY: sync
sync:
	@echo "Syncing dotfiles..."
	git add .
	git commit -m "chore: auto-sync dotfiles"
	git pull --rebase
	git push

.PHONY: hm-rebuild
hm-rebuild:
	@echo "Rebuilding home-manager configuration..."
	git add .
	home-manager switch --verbose --flake .#${USER} --show-trace

.PHONY: nixos-rebuild
nixos-rebuild:
	@echo "Rebuilding NixOS..."
	sudo cp nixos/configuration.nix /etc/nixos/configuration.nix
	sudo cp nixos/laptop-configuration.nix /etc/nixos/laptop-configuration.nix
	sudo cp nixos/pi-instances.nix /etc/nixos/pi-instances.nix
	sudo nixos-rebuild switch

.PHONY: update
update:
	nix flake update
	@echo "All updates completed"

.PHONY: clean
clean:
	@echo "Running garbage collection..."
	nix-collect-garbage -d --verbose
	sudo nix-collect-garbage --delete-older-than 7d

.PHONY: check
check:
	@echo "Checking flake..."
	nix flake check

.PHONY: reboot
reboot:
	@echo "Updating and rebooting NixOS"
	sudo nixos-rebuild boot --upgrade


.DEFAULT_GOAL := help
