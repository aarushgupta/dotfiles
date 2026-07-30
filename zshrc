# Sourced from the host's own ~/.zshrc by install.sh, never symlinked over it: the host
# appends its env setup to ~/.zshrc after dotfiles run, and that must land in the host's
# file rather than in this git checkout.

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

bindkey -v
export PATH="$HOME/.local/bin:$PATH"

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi
