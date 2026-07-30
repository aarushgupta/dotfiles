# Sourced from the host's ~/.bashrc. Hands interactive sessions to zsh and leaves
# non-interactive bash alone, so IDE remote helpers and startup scripts are unaffected.
#
# Caveat: if the host sources this above lines it appends later, exec'ing here skips them
# (e.g. a umask, cache dir, or project venv on PATH). Re-set anything that matters below.
case $- in
  *i*) [ -z "${ZSH_VERSION:-}" ] && command -v zsh >/dev/null 2>&1 && exec zsh ;;
esac
