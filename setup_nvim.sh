#!/bin/bash
set -e

echo ">>> 1. Updating System & Installing Dependencies..."
# Basic tools needed for Neovim (ripgrep for search, git for plugins)
sudo apt-get update
sudo apt-get install -y build-essential ripgrep fd-find unzip git curl

# Fix fd-find naming on Ubuntu (Standard fix)
if [ ! -f ~/.local/bin/fd ]; then
  mkdir -p ~/.local/bin
  ln -s $(which fdfind) ~/.local/bin/fd
fi
export PATH="$HOME/.local/bin:$PATH"

echo ">>> 2. Installing Rust toolchain..."
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
. "$HOME/.cargo/env"

echo ">>> 3. Building tree-sitter-cli from source (avoids GLIBC 2.39 incompatibility)..."
if ! command -v tree-sitter &>/dev/null; then
  cargo install tree-sitter-cli@0.25.6
fi
export PATH="$HOME/.cargo/bin:$PATH"

echo ">>> 4. Installing Latest Neovim (Snap)..."
sudo snap remove nvim 2>/dev/null || true
sudo snap install nvim --classic

echo ">>> 5. Cloning Your Configuration..."
if [ -d "$HOME/.config/nvim" ]; then
  echo "Backing up existing config..."
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi

# Clones your config
git clone https://github.com/danieljoseph18/nvim-config.git "$HOME/.config/nvim"

echo ">>> 6. Cleaning old Tree-sitter artifacts..."
rm -rf "$HOME/.local/share/nvim/mason/packages/tree-sitter-cli"
mkdir -p "$HOME/.local/share/nvim/mason/bin"
ln -sf "$HOME/.cargo/bin/tree-sitter" "$HOME/.local/share/nvim/mason/bin/tree-sitter"
rm -rf "$HOME/.local/share/nvim/tree-sitter-cli"

echo ">>> 7. Syncing Plugins..."
# Headless sync
nvim --headless "+Lazy! sync" +qa

echo ""
echo ">>> DONE! Open Neovim with 'nvim'"
