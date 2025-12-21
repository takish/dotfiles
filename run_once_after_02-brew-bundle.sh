#!/bin/bash
# Install Homebrew packages from Brewfile
# This runs AFTER other chezmoi files are applied

set -e

echo "Installing Homebrew packages from Brewfile..."

# chezmoi source directory にある Brewfile を使用
cd ~/.local/share/chezmoi

# brew bundle を実行（既存パッケージはアップグレードしない）
brew bundle --no-upgrade

echo "Homebrew packages installed successfully"