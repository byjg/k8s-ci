# tools-env.sh: what the installed tools need in the shell (JAVA_HOME, a folder on the
# PATH). load.sh writes it to ~/.shellscript/shellrc, which a terminal loads; a job is
# not a terminal. The image loads this file in every bash (BASH_ENV), and the entrypoint
# before it runs the command.
#
# The files are the ones of 'ci', whoever runs the job, and whatever its HOME is.
__tools_env_home="${HOME-}"
HOME="/home/ci"
for __tools_env_file in "$HOME"/.shellscript/shellrc/*.sh; do
  # The completion of the commands is for a terminal
  case "$__tools_env_file" in *completion*) continue ;; esac
  if [ -r "$__tools_env_file" ]; then . "$__tools_env_file"; fi
done
HOME="$__tools_env_home"
unset __tools_env_home __tools_env_file
