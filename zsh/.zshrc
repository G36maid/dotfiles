# Created by newuser for 5.9

# Fcitx5 environment variables
# export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx5
export GLFW_IM_MODULE=ibus

# firefox setting
export MOZ_ENABLE_WAYLAND=1

### Deno environment ###
if [ -f "$HOME/.deno/env" ]; then
  . "$HOME/.deno/env"
fi

### PATH setup ###
export PATH="$HOME/.deno/bin:$HOME/.local/bin:$PATH"


### editor setup ###
export EDITOR="vim"

# tpi: launch pi in a per-project tmux session (pi-interactive-subagents
# spawns its subagent panes off the parent pane, so pi must run inside tmux).
tpi() {
  if [ -n "$TMUX" ]; then
    command pi "$@"
    return
  fi
  local session="pi-$(basename "$PWD")-$(printf %s "$PWD" | md5sum | cut -c1-4)"
  local cmd="pi${*:+ $*}"
  if tmux has-session -t "$session" 2>/dev/null; then
    tmux new-window -t "$session" -c "$PWD" "$cmd"
    tmux attach-session -t "$session"
  else
    tmux new-session -s "$session" -c "$PWD" "$cmd"
  fi
}

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  # Portable bootstrap: pacman installs zimfw to /usr/share/zimfw, the official
  # installer puts it at ${ZIM_HOME}/zimfw.zsh.
  if [[ -e /usr/share/zimfw/zimfw.zsh ]]; then
    source /usr/share/zimfw/zimfw.zsh init
  else
    source ${ZIM_HOME}/zimfw.zsh init
  fi
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

### zoxide (smarter cd) ###
# `--cmd cd` replaces `cd` with a frecency-ranked jumper; `cdi` opens an
# fzf-powered interactive picker. Change to no flag for classic `z`/`zi`.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
fi

#starship
#eval "$(starship init zsh)"


# Added by Antigravity CLI installer
export PATH="/home/g36maid/.local/bin:$PATH"
