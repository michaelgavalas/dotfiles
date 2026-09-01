# ==============================================================================
# History
# ==============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# ==============================================================================
# General shell options
# ==============================================================================
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT
WORDCHARS=${WORDCHARS//[\/.]/}

# ==============================================================================
# zinit (self-bootstrapping plugin manager, clones itself on a fresh machine)
# ==============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

autoload -Uz compinit && compinit

# ==============================================================================
# Prompt
# ==============================================================================
eval "$(starship init zsh)"

# ==============================================================================
# fzf (fuzzy finder: ctrl+r history, ctrl+t file search, alt+c cd)
# ==============================================================================
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ==============================================================================
# zoxide (smart directory jumping: z <partial name>, zi for interactive)
# ==============================================================================
eval "$(zoxide init zsh)"

# ==============================================================================
# Core tool replacements
# ==============================================================================
alias fd=fdfind
alias bat=batcat
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias cat='batcat --paging=never'
alias grep='rg'
alias find='fdfind'

# ==============================================================================
# Environment (ported over from the old .bashrc)
# ==============================================================================
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -f "$HOME/snap/code/254/.local/share/../bin/env" ] && source "$HOME/snap/code/254/.local/share/../bin/env"

alias dev='cd ~/dev'
alias claude='claude --dangerously-skip-permissions'
alias tn='tmux new -s'
alias ta='tmux attach -t'

# yazi: cd the shell into whatever directory yazi was in when it quit
function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}
alias fix-mounts="fusermount3 -u -z ~/develop/home ~/develop/projects 2>/dev/null; sudo systemctl restart remote-fs.target"

# Reset terminal mouse tracking before every prompt
safe_prompt() {
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1005l\e[?1006l'
}
precmd_functions+=(safe_prompt)
