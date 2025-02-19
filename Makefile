.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Setup:"
	@echo "  deps                  Install Nix dependencies"
	@echo "  init                  Initialize dotfile symlinks"
	@echo ""
	@echo "Daily commands:"
	@echo "  rebuild               Rebuild home manager configuration"
	@echo "  sync                  Sync dotfiles with git repository"
	@echo ""
	@echo "Maintenance:"
	@echo "  update                Update both nixpkgs and home-manager"
	@echo "  clean                 Run garbage collection"
	@echo "  check                 Check nix flake for errors"

.PHONY: deps
deps:
	@echo "Installing dependencies.."
	@command nix --version >/dev/null 2>&1 || echo "Install Nix: curl -L https://nixos.org/nix/install | sh"

.PHONY: init
CONFIGS := i3
init:
	@echo "Initializing dotfile symlinks.. ${CONFIGS}"
	@for c in $(CONFIGS); do \
		[ -d ~/.config/$$c ] && rm -rf ~/.config/$$c || true; \
		ln -sf $(PWD)/.config/$$c ~/.config/$$c; \
	done

.PHONY: rebuild
rebuild:
	@echo "Rebuilding home-manager configuration..."
	git add .
	home-manager switch --verbose --flake .#${USER} --show-trace

.PHONY: sync
sync:
	@echo "Syncing dotfiles.."
	git add .
	git commit -m "chore: auto-sync dotfiles"
	git pull --rebase
	git push

.PHONY: update
update:
	nix flake update
	@echo "All updates completed"

.PHONY: clean
clean:
	@echo "Running garbage collection.."
	nix-collect-garbage -d --verbose

.PHONY: check
check:
	@echo "Checking flake.."
	nix flake check

.DEFAULT_GOAL := help
