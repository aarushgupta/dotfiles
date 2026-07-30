# Sourced from the host's ~/.bashrc. Hands real interactive terminals to zsh.
#
# Guards, in order: interactive only, so scripts and IDE remote helpers are untouched;
# no -c command, because `exec` would discard it (tools probe env with `bash -ilc '...'`);
# and stdout must be a tty.
#
# Caveat: if the host sources this above lines it appends later, exec'ing here skips them
# (e.g. a umask, cache dir, or project venv on PATH). Re-set anything that matters below.
case $- in
  *i*)
    if [ -z "${BASH_EXECUTION_STRING:-}" ] && [ -z "${ZSH_VERSION:-}" ] && [ -t 1 ] &&
      command -v zsh >/dev/null 2>&1; then
      exec zsh
    fi
    ;;
esac
