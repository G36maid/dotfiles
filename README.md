# dotfiles

My Arch Linux + Hyprland dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## screenshots

![Desktop screenshot](screenshot.png)

## Contents

- [System](#system)
- [Requirements](#requirements)
  - [Core (pacman)](#core-pacman)
  - [Runtime deps](#runtime-deps)
  - [Fonts](#fonts)
- [Install](#install)
- [Structure](#structure)
- [Post-install steps](#post-install-steps)
  - [TPM (tmux plugin manager)](#tpm-tmux-plugin-manager)
  - [Zim (zsh framework)](#zim-zsh-framework)
  - [`oc()` — opencode + tmux wrapper](#oc--opencode--tmux-wrapper)
  - [System-level configs (not stowed)](#system-level-configs-not-stowed)
- [Pre-install: back up existing dotfiles](#pre-install-back-up-existing-dotfiles)
- [Secrets policy](#secrets-policy)
- [License](#license)

## System

- **OS**: Arch Linux
- **WM**: Hyprland (Wayland)
- **Shell**: zsh (zim framework)
- **Terminal**: kitty
- **Editor**: vim + zed
- **Input method**: fcitx5 (mcbopomofo)

## Requirements

### Core (pacman)

```bash
sudo pacman -S --needed stow zsh tmux vim kitty hyprland waybar wofi \
  fastfetch fcitx5 zellij yazi btop htop bottom bashtop lazygit lazydocker \
  starship gdb zimfw
```

### Runtime deps

Additional binaries referenced by Hyprland keybinds and `autostart.conf`. Without these, the corresponding keys / tray icons will silently do nothing:

```bash
sudo pacman -S --needed hyprshot hypridle hyprlock hyprpaper playerctl \
  brightnessctl wireplumber network-manager-applet blueman
```

| Tool | Where it's used |
|---|---|
| `hyprshot` | Screenshot binds — `Print` (output), `Super+Print` (window), `Shift+Print` (region) |
| `playerctl` | Media keys (`XF86AudioNext/Play/Prev`) |
| `brightnessctl` | Brightness + keyboard-backlight keys |
| `wireplumber` (`wpctl`) | Volume up/down/mute + mic mute keys |
| `nm-applet` / `blueman-applet` | Autostart tray icons (network / bluetooth) |
| `hypridle` / `hyprlock` / `hyprpaper` | Autostart (idle daemon, screen locker, wallpaper) |

### Fonts

A **Nerd Font** is required — kitty, starship, waybar, and yazi all render Nerd Font glyphs, and kitty is pinned to `FiraCode Nerd Font`:

```bash
sudo pacman -S --needed ttf-firacode-nerd
```

> TPM (tmux plugin manager) is installed via git clone — see [Post-install steps](#tpm-tmux-plugin-manager).

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

> If `stow */` reports conflicts, real (non-symlink) files already exist at the target paths — see [Pre-install: back up existing dotfiles](#pre-install-back-up-existing-dotfiles).

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
| `hypr/` | `.config/hypr/` (hyprland, hypridle, hyprlock, hyprpaper, modules/) |
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
| `opencode/` | `.config/opencode/{opencode.jsonc,oh-my-openagent.json,package.json}` |
| `misc/` | `.config/`: `QtProject.conf`, `hyfetch.json`, `dolphinrc`, `mimeapps.list`, `code-flags.conf` |

> The `hypr/` config is split into per-concern files under `.config/hypr/modules/` (`general`, `input`, `binds`, `env`, `monitors`, `rules`, `autostart`), all sourced by `hyprland.conf` — edit one concern without touching the rest.

## Post-install steps

### TPM (tmux plugin manager)

`.tmux.conf` references TPM. After stowing:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.tmux.conf
# Press prefix + I (capital i) inside tmux to install plugins
# (prefix is Ctrl+b — see `set -g prefix C-b` in .tmux.conf)
```

### Zim (zsh framework)

`.zshrc` bootstraps zim automatically on first login via `/usr/share/zimfw/zimfw.zsh`. Just make sure the `zimfw` package (listed in [Requirements](#requirements)) is installed — zim will self-initialize on first shell launch.

### `oc()` — opencode + tmux wrapper

`.zshrc` defines an `oc()` function that launches [opencode](https://opencode.ai/) inside a dedicated tmux session, named after the current directory, and auto-selects a free port in `4096–5096` (exported as `$OPENCODE_PORT`):

```bash
oc            # fresh named session for $PWD, attaches if it already exists
oc --resume   # any args pass through to opencode
```

- If a session named `<dir>-<hash>` already exists for this path, it re-attaches instead of spawning a duplicate.
- Already inside tmux? It opens a new window in the current session rather than nesting.

### System-level configs (not stowed)

`pacman.conf` and `paru.conf` live under `/etc/` and are not tracked here — they're upstream-managed (pacman ships `.pacnew` updates) and not worth fighting stow's `$HOME` model for. Reproduce the customizations manually:

**`/etc/pacman.conf`** — enable `Color`, `ParallelDownloads`, and `[multilib]`:

```bash
sudo sed -i \
  -e 's/^#Color$/Color/' \
  -e 's/^#ParallelDownloads = 5$/ParallelDownloads = 5/' \
  -e '/^\[multilib\]$/,/^Include = \/etc\/pacman.d\/mirrorlist$/ s/^#//' \
  /etc/pacman.conf
```

**`/etc/paru.conf`** — restore via paru's own save flag (preferred over editing by hand):

```bash
paru --bottomup --devel --provides --pgpfetch --fm yazi --save
```

## Pre-install: back up existing dotfiles

`stow */` symlinks these files into `$HOME`. If real (non-symlink) versions already exist at the target paths, stow will refuse with a conflict. Move them aside first:

```bash
mkdir -p ~/.config-backup
mv ~/.zshrc ~/.zimrc ~/.tmux.conf ~/.vimrc ~/.gitconfig ~/.gdbinit \
   ~/.bashrc ~/.bash_profile ~/.config-backup/ 2>/dev/null
stow */
```

Alternatively, `stow --adopt */` overwrites the stow package's copy with your existing files (useful if you want to capture your current setup into this repo).

## Secrets policy

This repo is **public**. The `.gitignore` blocks known secret-bearing files (`hosts.yml`, `development_credentials`, `*.session`, SSH/GPG/Docker/K8s dirs, `.npmrc`, `.claude.json`, etc.). Verify with:

```bash
git ls-files | xargs grep -Eni 'gh[ops]_|sk-or-|api_key|token|password|SECRET' || echo clean
```

## License

No license file is included. These are personal configs shared publicly for reference; default copyright applies — fork and adapt for your own use, but no rights are formally granted.
