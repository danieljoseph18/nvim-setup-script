#!/bin/bash
set -e # Exit on error

echo ">>> 1. Updating System & Installing Dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential ripgrep fd-find unzip git curl

# Fix fd-find naming on Ubuntu
if [ ! -f ~/.local/bin/fd ]; then
  mkdir -p ~/.local/bin
  ln -s $(which fdfind) ~/.local/bin/fd
fi

echo ">>> 2. Installing Rust (Required for Tree-sitter fix)..."
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

echo ">>> 3. Installing Latest Neovim (Snap)..."
# Removes old version if present
sudo snap remove nvim 2>/dev/null || true
sudo snap install nvim --classic

echo ">>> 4. Compiling Tree-Sitter CLI (The GLIBC Fix)..."
# This prevents the version mismatch error we faced
cargo install tree-sitter-cli --locked

echo ">>> 5. Cloning Your Configuration..."
# Back up existing config if it exists
if [ -d "$HOME/.config/nvim" ]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi

# Clone YOUR repo (Replace with your actual URL)
git clone https://github.com/danieljoseph18/nvim-config.git "$HOME/.config/nvim"

echo ">>> 6. Forcing Neovim to use our custom Tree-Sitter..."
# Remove the downloaded binary so it uses the cargo installed one
rm -rf "$HOME/.local/share/nvim/tree-sitter-cli"
mkdir -p "$HOME/.local/share/nvim"

echo ">>> 7. Installing Plugins..."
# Headless install of plugins
nvim --headless "+Lazy! sync" +qa

echo ">>> DONE! Open Neovim with 'nvim'"
