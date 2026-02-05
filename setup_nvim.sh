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

echo ">>> 2. Installing Latest Neovim (Snap)..."
sudo snap remove nvim 2>/dev/null || true
sudo snap install nvim --classic

echo ">>> 3. Cloning Your Configuration..."
if [ -d "$HOME/.config/nvim" ]; then
  echo "Backing up existing config..."
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi

# Clones your config
git clone https://github.com/danieljoseph18/nvim-config.git "$HOME/.config/nvim"

echo ">>> 4. Cleaning old Tree-sitter artifacts..."
# Ensure we start fresh so the plugin downloads what it needs
rm -rf "$HOME/.local/share/nvim/tree-sitter-cli"

echo ">>> 5. Syncing Plugins..."
# Headless sync
nvim --headless "+Lazy! sync" +qa

echo ""
echo ">>> DONE! Open Neovim with 'nvim'"
