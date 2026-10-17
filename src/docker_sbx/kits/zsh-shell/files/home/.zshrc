# Sandbox environment (proxy settings and anything kits persisted for bash).
[ -f /etc/sandbox-persistent.sh ] && source /etc/sandbox-persistent.sh

export ZSH="$HOME/.oh-my-zsh"
# Empty theme: starship draws the prompt.
ZSH_THEME=""
DISABLE_AUTO_UPDATE="true"
plugins=(git aws)
source "$ZSH/oh-my-zsh.sh"

HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY

eval "$(starship init zsh)"
