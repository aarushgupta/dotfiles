#!/usr/bin/env bash
# Run from the dotfiles checkout on every boot by the host's dotfiles feature.
#
# ~/.zshrc, ~/.bashrc and ~/.gitconfig belong to the host image, which appends its own env
# and git credential setup to them - sometimes after this script runs. So nothing here
# replaces those files: we append one guarded line and let `git config --global` merge.
# Symlinking them would redirect the host's appends into this git checkout and can drop
# credential settings the environment needs in order to clone.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

# zsh: source our config from the host's own ~/.zshrc, early enough that later appends win.
touch "$HOME/.zshrc"
if ! grep -qF "$REPO/zshrc" "$HOME/.zshrc"; then
  printf '\n. "%s/zshrc"\n' "$REPO" >> "$HOME/.zshrc"
  echo "appended source line to ~/.zshrc"
fi

# bash: some hosts already source <checkout>/.bashrc themselves; only add the line if absent.
touch "$HOME/.bashrc"
if ! grep -q 'dotfiles/\.bashrc' "$HOME/.bashrc"; then
  printf '\n. "%s/.bashrc"\n' "$REPO" >> "$HOME/.bashrc"
  echo "appended source line to ~/.bashrc"
fi

# git: --global merges into the host's ~/.gitconfig instead of replacing it.
git config --global user.name "Aarush Gupta"
git config --global core.excludesfile "$REPO/gitignore_global"
email="${GIT_EMAIL:-${CODER_USER:-}}"
if [ -n "$email" ]; then
  git config --global user.email "$email"
  echo "set git user.email to $email"
else
  echo "install: no \$GIT_EMAIL or \$CODER_USER; set git user.email yourself" >&2
fi

# nvim config is ours alone, so a symlink is safe here.
mkdir -p "$HOME/.config/nvim"
if [ -e "$HOME/.config/nvim/init.lua" ] && [ ! -L "$HOME/.config/nvim/init.lua" ]; then
  mv "$HOME/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua.bak"
  echo "backed up existing init.lua"
fi
ln -sfn "$REPO/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Heal damage from an older revision that symlinked ~/.claude/CLAUDE.md into the
# checkout: hosts regenerate that file at boot, and writing through the symlink
# after the checkout moved could crash startup. Only touches a dangling symlink.
if [ -L "$HOME/.claude/CLAUDE.md" ] && [ ! -e "$HOME/.claude/CLAUDE.md" ]; then
  rm -f "$HOME/.claude/CLAUDE.md"
  if [ -f "$HOME/.claude/CLAUDE.md.bak" ]; then
    mv "$HOME/.claude/CLAUDE.md.bak" "$HOME/.claude/CLAUDE.md"
  fi
  echo "removed dangling CLAUDE.md symlink"
fi

exec "$REPO/personalize.sh"
