# dotfiles

Personal dotfiles for remote dev environments. Point your platform's dotfiles setting at
`aarushgupta/dotfiles`; it clones the repo on every boot and runs `install.sh`.

Use the full HTTPS URL (`https://github.com/aarushgupta/dotfiles`) — some hosts expand the
`owner/repo` short form, but Coder's `coder dotfiles` passes the string straight to `git clone`,
which reads it as a local path. SSH URLs can't authenticate in a container.

| file | what it does |
| --- | --- |
| `zshrc` | oh-my-zsh (`robbyrussell`, git + autosuggestions + syntax-highlighting), vi keybindings, `$EDITOR` |
| `.bashrc` | hands interactive bash to zsh |
| `gitignore_global` | python/ML ignores, wired via `core.excludesfile` |
| `nvim/init.lua` | lazy.nvim + nvim-cmp + pyright LSP |
| `install.sh` | appends source lines, sets git config, links nvim, then runs `personalize.sh` |
| `personalize.sh` | idempotent: oh-my-zsh + plugins, neovim, `chsh` to zsh |

## Append, don't replace

`~/.zshrc`, `~/.bashrc` and `~/.gitconfig` usually belong to the host image, which appends its own
env setup and git credential config to them — sometimes *after* dotfiles run. Symlinking ours over
theirs means those appends land inside this git checkout (dirtying it, so the next boot's `git pull`
fails) and can drop credential settings the environment needs to clone anything.

So `install.sh` appends one guarded `.` line per shell file and uses `git config --global`, which
merges. Only `~/.config/nvim/init.lua` is symlinked, since nothing else owns it.

## Notes

- zsh is assumed present; only oh-my-zsh and its two plugins are layered on top.
- No email is committed here. `install.sh` sets `user.email` from `$GIT_EMAIL` or `$CODER_USER` and
  warns if neither exists. Check with `git config user.email`.
- neovim comes from the official static tarball into `~/.local/nvim`; distro packages are often too
  old for the `vim.lsp.config` API used in `nvim/init.lua`. `pyright` installs on first Python buffer.
- Private repo: cloning uses a GitHub App **user-to-server** token, which only reaches repos where
  the app is *installed* on your account. Authorizing an app is not sufficient — install it on your
  personal account with this repo selected.
