#!/usr/bin/env bash

TARGET_HOST="${1:-}"
TARGET_USER="${2:-kristian}"


if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! $(basename "$0") should be run as a regular user"
  exit 1
fi

if [ ! -d "$HOME/dev/nix-config/.git" ]; then
  GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git clone git@github.com:krkind/nix-config.git "$HOME/dev/nix-config"
fi

cd "$HOME/dev/kristian-nix"

if [[ -z "$TARGET_HOST" ]]; then
  echo "ERROR! $(basename "$0") requires a hostname as the first argument"
  echo "       The following hosts are available"
  ls -1 nixos/*/boot.nix | cut -d'/' -f2 | grep -v iso
  exit 1
fi

if [[ -z "$TARGET_USER" ]]; then
  echo "ERROR! $(basename "$0") requires a username as the second argument"
  echo "       The following users are available"
  ls -1 nixos/_mixins/users/ | grep -v -E "nixos|root"
  exit 1
fi

if [ ! -e "nixos/surface-go-4/disks.nix" ]; then
  echo "ERROR! $(basename "$0") could not find the required nixos/surface-go-4/disks.nix"
  exit 1
fi

sudo true

sudo nix run github:nix-community/disko \
  --extra-experimental-features "nix-command flakes" \
  --no-write-lock-file \
  -- \
  --mode zap_create_mount \
  "nixos/surface-go-4/disks.nix"

sudo nixos-install --no-root-password --flake ".#$TARGET_HOST"

sudo chown -R 1000:100 /mnt/home/$TARGET_USER
# Rsync nix-config to the target install and set the remote origin to SSH.
rsync -a --delete "$HOME/dev/" "/mnt/home/$TARGET_USER/dev/"

sudo mkdir -p "/mnt/home/$TARGET_USER/.ssh"
sudo cp "$HOME/.ssh/id_rsa" "/mnt/home/$TARGET_USER/.ssh/id_rsa"
sudo chmod 600 "/mnt/home/$TARGET_USER/.ssh/id_rsa"
sudo chown -R 1000:100 "/mnt/home/$TARGET_USER/.ssh"

# Tell the user that the installation is complete
echo "**Installation complete! Reboot the system and login as $TARGET_USER"