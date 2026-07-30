#!/usr/bin/env bash
# Idempotent per-startup setup. Runs on every workspace start, so every step is guarded
# and a network failure warns instead of failing the whole startup script.
set -uo pipefail

warn() { echo "personalize: $* (skipped)" >&2; }

# oh-my-zsh — plain clone, not the curl installer (that one rewrites .zshrc).
# zsh itself is already in the image; we only layer omz + plugins on top.
ZSH_DIR="$HOME/.oh-my-zsh"
[ -d "$ZSH_DIR" ] || git clone -q --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR" ||
  warn "oh-my-zsh clone failed"

for p in zsh-autosuggestions zsh-syntax-highlighting; do
  d="$ZSH_DIR/custom/plugins/$p"
  [ -d "$d" ] || git clone -q --depth=1 "https://github.com/zsh-users/$p.git" "$d" ||
    warn "$p clone failed"
done

# neovim — apt ships 0.9, too old for the vim.lsp.config API in nvim/init.lua.
if ! command -v nvim >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/nvim" "$HOME/.local/bin"
  if curl -fsSL https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz |
    tar -xz --strip-components=1 -C "$HOME/.local/nvim"; then
    ln -sfn "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  else
    warn "neovim download failed"
  fi
fi

# Default shell -> zsh. /etc/passwd is image state, so this re-applies after a rebuild.
zsh_path="$(command -v zsh || true)"
if [ -n "$zsh_path" ] && [ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$zsh_path" ]; then
  chsh -s "$zsh_path" "$(id -un)" 2>/dev/null || warn "chsh to $zsh_path failed"
fi

echo "personalize: done"
