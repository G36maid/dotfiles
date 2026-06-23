# dotfiles

My Arch Linux + Hyprland dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## System

- **OS**: Arch Linux
- **WM**: Hyprland (Wayland)
- **Shell**: zsh (zim framework)
- **Terminal**: kitty
- **Editor**: vim + zed
- **Input method**: fcitx5 (mcbopomofo)

## Requirements

```bash
sudo pacman -S --needed stow zsh tmux vim kitty hyprland waybar wofi \
  fastfetch fcitx5 zellij yazi btop htm bottom bashtop lazygit lazydocker \
  starship gdb
paru -S tpm    # tmux plugin manager (AUR)
```

## Install

```bash
git clone git@github.com:G36maid/dotfiles.git ~/Github/dotfiles
cd ~/Github/dotfiles

# Stow every package (symlinks into $HOME)
stow */

# Or pick individual packages
stow zsh hypr kitty waybar
```

To remove a package: `stow -D <package>`

## Structure

Each top-level directory is a Stow package that mirrors its target path under `$HOME`.

| Package | Contents |
|---|---|
| `zsh/` | `.zshrc` (zim + custom `oc()` fn), `.zimrc` (zimfw modules) |
| `bash/` | `.bashrc`, `.bash_profile` |
| `tmux/` | `.tmux.conf` (dracula theme via TPM) |
| `vim/` | `.vimrc` |
| `git/` | `.gitconfig` |
| `gdb/` | `.gdbinit` |
| `starship/` | `.config/starship.toml` |
| `hypr/` | `.config/hypr/` (hyprland, hypridle, hyprpaper, modules/) |
| `kitty/` | `.config/kitty/kitty.conf` |
| `wofi/` | `.config/wofi/` (launcher + menus) |
| `waybar/` | `.config/waybar/` (bar + power menu) |
| `fastfetch/` | `.config/fastfetch/` (with lain logos) |
| `fcitx5/` | `.config/fcitx5/` (mcbopomofo + classicui) |
| `zellij/` | `.config/zellij/config.kdl` |
| `yazi/` | `.config/yazi/` |
| `zed/` | `.config/zed/` (settings, keymap, tasks) |
| `monitors/` | `.config/{btop,htop,bottom,bashtop}/` |
| `lazytuis/` | `.config/{lazygit,lazydocker}/` |
| `opencode/` | `.config/opencode/{opencode,oh-my-openagent}.json` |
| `misc/` | Various small XDG configs (mimeapps, code-flags, etc.) |

## Post-install steps

### TPM (tmux plugin manager)

`.tmux.conf` references TPM. After stowing:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.tmux.conf
# Press prefix + I (capital i) inside tmux to install plugins
```

### Zim (zsh framework)

`.zshrc` bootstraps zim automatically on first login via `/usr/share/zimfw/zimfw.zsh`. Install the `zimfw` package first:

```bash
sudo pacman -S zimfw
```

## Secrets policy

This repo is **public**. The `.gitignore` blocks known secret-bearing files (`hosts.yml`, `development_credentials`, `*.session`, etc.). Verify with:

```bash
git ls-files | xargs grep -Eni 'gh[ops]_|sk-or-|api_key|token|password|SECRET' || echo clean
```

## Backup

A pre-migration backup lives at `~/dotfiles-backup-<timestamp>.tar.gz`.
