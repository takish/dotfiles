#!/bin/bash
# Create convenient symlinks

# Obsidian vault
OBSIDIAN_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/myvault"
if [ -d "$OBSIDIAN_PATH" ] && [ ! -e "$HOME/notes" ]; then
    ln -s "$OBSIDIAN_PATH" "$HOME/notes"
    echo "Created symlink: ~/notes -> Obsidian vault"
fi
