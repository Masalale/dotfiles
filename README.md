# dotfiles

My shell configuration — backed up automatically.

## Contents
- `.zshrc` — Zsh config (Zinit, p10k, fzf-tab, aliases, `upgrade` function)
- `.p10k.zsh` — Powerlevel10k theme
- `.zshenv` — Environment (vite+, cargo)
- `.gitconfig` — Git defaults

## Install
```bash
git clone https://github.com/Masalale/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/.zshenv ~/.zshenv
source ~/.zshrc
```

## Sync
```bash
cp ~/.zshrc ~/dotfiles/.zshrc && cp ~/.p10k.zsh ~/dotfiles/.p10k.zsh
git -C ~/dotfiles add -A && git commit -m "chore: sync dotfiles" && git push
```
