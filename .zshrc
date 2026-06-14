export EDITOR=nvim
export MANPAGER='nvim +Man!'
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export LS_COLORS="$LS_COLORS:ow=01;36:"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt inc_append_history
setopt share_history
setopt histignoredups
setopt interactive_comments

autoload -Uz +X compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

alias vim='nvim'
alias grep='rg'
alias ani='ani-cli'
alias cat='bat'
alias lsblk='lsblk | bat -l conf -p'
alias cd='z'
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias du='du -h'

function h() {
  if [[ $# -eq 0 ]]; then
    echo "\e[1;32mUsage:\e[0m h [command]\n\e[1;36mPrint the help page of a command in bat.\e[0m"
  else
    $1 --help | bat -l help
  fi
}

bindkey -e # the vim mode in enabled if $EDITOR is set to vim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^e' end-of-line
bindkey '^x' edit-command-line

hexyl() {
    /opt/homebrew/bin/hexyl "$@" | bat -p
}

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "/Users/david/.zsh-fzf-tab/fzf-tab.plugin.zsh"
