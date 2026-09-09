#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

### Aliases ###
alias ls='ls --color=auto'
alias grep='grep --color=auto'

### Input method (fcitx5) ###
# export GTK_IM_MODULE=fcitx5  # uncomment if you need GTK apps
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx5
export GLFW_IM_MODULE=ibus

### Firefox Wayland support ###
export MOZ_ENABLE_WAYLAND=1

### PATH setup ###
# Add custom paths only if not already in PATH
for p in "$HOME/.local/bin"; do
  case ":$PATH:" in
    *":$p:"*) ;; # already in PATH
    *) export PATH="$p:$PATH" ;;
  esac
done
