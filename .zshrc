# --- p10k instant prompt ---
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# --- startup ---
if command -v nerdfetch >/dev/null 2>&1; then
  nerdfetch 2>/dev/null
fi
echo

# --- plugins (Zinit) ---
source "$HOME/.local/share/zinit/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps[_zinit]} )) && _comps[_zinit]=_zinit

zinit ice depth'1'
zinit light zsh-users/zsh-autosuggestions
zinit ice depth'1'
zinit light zsh-users/zsh-syntax-highlighting
zinit ice depth'1'
zinit light romkatv/powerlevel10k
zinit ice depth'1'
zinit light Aloxaf/fzf-tab
zinit ice depth'1'
zinit light zap-zsh/supercharge
zinit ice depth'1'
zinit light zap-zsh/sudo
zinit ice pick"distro-prompt.zsh-theme" depth'1'
zinit light MAHcodes/distro-prompt

# --- completion setup ---
autoload -Uz compinit
compinit

# --- theme ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- key bindings ---
bindkey "^[[3~" delete-char
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word

# --- aliases ---
alias src="clear && source ~/.zshrc"
alias rc="sudo nvim ~/.zshrc"

alias cls="clear"
alias ll="ls -Alh"
alias ls="lsd --group-dirs first"
alias cat="bat"
alias icat="/mnt/c/Program\ Files/WezTerm/wezterm.exe imgcat"
alias dnf="dnf -y"
alias sdi="sudo dnf install"
alias sdr="sudo dnf remove"
alias sdri="sudo dnf reinstall"
alias sds="sudo dnf search"

# --- upgrade: system + AI CLI tools ---
unalias upgrade 2>/dev/null   # clear stale alias from previously-sourced shell
upgrade() {
  sudo dnf upgrade -y
  local tools=(bun vp pi opencode claude codex hermes)
  local failed=()
  for t in $tools; do
    print -P "%F{cyan}── %B$t%b ──%f"
    case $t in
      bun)      bun upgrade ;;
      vp)       vp upgrade ;;
      pi)       pi update ;;
      opencode) opencode upgrade ;;
      claude)   claude update ;;
      codex)    codex update ;;
      hermes)   hermes update ;;
    esac
    if [[ $? -ne 0 ]]; then failed+=($t); fi
  done
  if (( ${#failed} )); then
    print -P "%F{red}✗ upgrade failed for: %B${(j:, :)failed}%b%f"
    return 1
  fi
  print -P "%F{green}✓ system & all tools up to date%f"
}
alias ctt="curl -fsSL https://christitus.com/linux | sh"
alias explorer="explorer.exe"
alias npm="bun"

# --- environment ---
export DOTNET_ROOT="$HOME/dotnet"
export JAVA_HOME="/usr/lib/jvm/java-25-temurin-jdk"
export BUN_INSTALL="$HOME/.bun"

export PATH="$DOTNET_ROOT:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

export GH_NO_TELEMETRY=1
export OPENCODE_DISABLE_PRUNE=true
export EDITOR="nvim"
export CLAUDETREE_LUA="/home/ngash/.local/share/claudetree"
export BAT_THEME="Monokai Extended"

# --- history ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY          # save timestamps with commands
setopt INC_APPEND_HISTORY        # add to history file immediately
setopt SHARE_HISTORY             # share history across sessions
setopt HIST_IGNORE_ALL_DUPS      # don't save duplicate lines
setopt HIST_IGNORE_SPACE         # don't save commands starting with space
setopt HIST_REDUCE_BLANKS        # trim whitespace
setopt HIST_VERIFY               # confirm before executing history expansion
setopt HIST_NO_STORE             # don't store history (fc -l) commands

# --- completions ---
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

export DOTNET_ROOT="/home/ngash/.dotnet"


source /home/ngash/.config/broot/launcher/bash/br

# OpenCode global session helpers
alias opencode-sessions="opencode-sessions-all"
alias opencode-resume="opencode-resume-any"
alias opencode-rollback="opencode-db-rollback"

# Force wrapper precedence so `opencode session list` is system-wide
export PATH="$HOME/.local/bin:$PATH"
alias opencode="$HOME/.local/bin/opencode"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# bun completions
[ -s "/home/ngash/.bun/_bun" ] && source "/home/ngash/.bun/_bun"

# Claude CLI with permissions bypass
alias claude="/home/ngash/.local/bin/claude --dangerously-skip-permissions"

# --- zoxide (must be the last thing initialized) ---
export _ZO_DOCTOR=0
# Defensive: some AI tools (Claude Code, OpenCode) emit `cs <dir>` as a typo
# for `cd <dir>`. Funnel it through zoxide's wrapper so the smart-jump still works.
alias cs='cd'
eval "$(zoxide init zsh --cmd cd)"
