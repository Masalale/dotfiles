# Ensure unique entries in PATH
typeset -U path PATH

# --- p10k instant prompt ---
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# --- startup ---
if command -v nerdfetch >/dev/null 2>&1; then
  nerdfetch 2>/dev/null
fi
echo

# --- completion setup ---
autoload -Uz compinit
setopt EXTENDED_GLOB
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) || ! -f ${ZDOTDIR:-$HOME}/.zcompdump ]]; then
  compinit
  touch "${ZDOTDIR:-$HOME}/.zcompdump"
else
  compinit -C
fi

# Byte-compile ~/.zcompdump in background if missing or outdated
{
  local dump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -s "$dump" && (! -s "${dump}.zwc" || "$dump" -nt "${dump}.zwc") ]]; then
    zcompile "$dump"
  fi
} &!

# Completion styles & quality-of-life options
zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist 2>/dev/null
_comp_options+=(globdots)       # include hidden files in completion
setopt AUTO_CD                  # type folder name to cd
setopt INTERACTIVE_COMMENTS     # allow comments in interactive shell

# --- plugins (Zinit) ---
source "$HOME/.local/share/zinit/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps[_zinit]} )) && _comps[_zinit]=_zinit

# Theme
zinit ice depth'1'
zinit light romkatv/powerlevel10k

# Tab completion via fzf
zinit ice depth'1'
zinit light Aloxaf/fzf-tab

# fzf-tab configuration & rich previews (lsd, bat, ps)
zstyle ':completion:complete:*:options' sort false
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always "$realpath"'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then lsd -1 --color=always "$realpath"; elif [[ -f $realpath ]]; then bat --style=numbers --color=always --line-range :100 "$realpath" 2>/dev/null; fi'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,%cpu,%mem,command -w"
zstyle ':fzf-tab:complete:(kill|pkill):*' fzf-preview '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|pkill):*' fzf-flags --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

# Double-Esc to toggle sudo (official Oh-My-Zsh plugin snippet)
zinit snippet OMZP::sudo

# Suggestions and syntax highlighting (syntax highlighting must load last)
zinit ice depth'1'
zinit light zsh-users/zsh-autosuggestions
zinit ice depth'1'
zinit light zsh-users/zsh-syntax-highlighting

# Note: MAHcodes/distro-prompt (your inclusion, commented out for testing)
# zinit ice pick"distro-prompt.zsh-theme" depth'1'
# zinit light MAHcodes/distro-prompt

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

# History search with prefix matching (type prefix, then press Up/Down)
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

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
  local tools=(bun pi opencode claude hermes agy)
  local failed=()
  for t in $tools; do
    print -P "%F{cyan}── %B$t%b ──%f"
    case $t in
      bun)      bun upgrade ;;
      pi)       pi update ;;
      opencode) "$HOME/.local/bin/opencode" upgrade ;;  # self-upgrade the standalone (~/.opencode/bin)
      claude)   claude update ;;
      hermes)   hermes update ;;
      agy)      command agy update ;;
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

# Bun package manager aliases
alias npm="bun"
alias npx="bunx"
alias pnpm="bun"
alias pnpx="bunx"
alias yarn="bun"

# --- environment ---
export DOTNET_ROOT="$HOME/.dotnet"
export JAVA_HOME="/usr/lib/jvm/java-25-temurin-jdk"
export BUN_INSTALL="$HOME/.bun"

# Prioritize local binaries and Bun
export PATH="$HOME/.local/bin:$BUN_INSTALL/bin:$DOTNET_ROOT:$DOTNET_ROOT/tools:$HOME/.opencode/bin:$HOME/.cargo/bin:$PATH"

export GH_NO_TELEMETRY=1
export OPENCODE_DISABLE_PRUNE=true
export EDITOR="nvim"
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

[ -f /home/ngash/.config/broot/launcher/bash/br ] && source /home/ngash/.config/broot/launcher/bash/br

# OpenCode global session helpers
alias opencode-sessions="opencode-sessions-all"
alias opencode-resume="opencode-resume-any"
alias opencode-rollback="opencode-db-rollback"

# Wrapper precedence alias so `opencode session list` is system-wide
alias opencode="$HOME/.local/bin/opencode"

# Claude CLI with permissions bypass
alias claude="/home/ngash/.local/bin/claude --dangerously-skip-permissions"

# Antigravity CLI with permissions bypass
alias agy="agy --dangerously-skip-permissions"

# --- zoxide (must be the last thing initialized) ---
export _ZO_DOCTOR=0
# Defensive: some AI tools (Claude Code, OpenCode) emit `cs <dir>` as a typo
# for `cd <dir>`. Funnel it through zoxide's wrapper so the smart-jump still works.
alias cs='cd'
eval "$(zoxide init zsh --cmd cd)"
