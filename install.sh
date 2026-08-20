#!/usr/bin/env bash
set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
for f in .zshrc .p10k.zsh .zshenv; do
  if [ -f "$DOTFILES_DIR/$f" ]; then
    ln -sf "$DOTFILES_DIR/$f" "$HOME/$f"
    echo "linked $f -> $HOME/$f"
  fi
done
echo "Done. Run: source ~/.zshrc"
