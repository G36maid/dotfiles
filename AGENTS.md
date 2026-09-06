# AGENTS.md

Dotfiles repo managed with **GNU Stow**. Each top-level dir is a stow package mirroring its path under `$HOME` (e.g. `zsh/.zshrc` → `~/.zshrc`). Repo lives at `~/Code/github/dotfiles`, so the target flag is mandatory:

```bash
stow --no-folding --target="$HOME" */   # default target (parent dir) is wrong here
```

## Hard rules

- **Repo is public — never commit secrets.** Secret-bearing files are gitignored and recreated per host: `pi/.pi/agent/auth.json`, `pi/.pi/web-search.json`, `opencode/.local/share/opencode/auth.json`. Check with:
  `git ls-files | xargs grep -Eni 'gh[ops]_|sk-or-|api_key|token|password|SECRET' || echo clean`
- **`headless` branch is generated — never merge into it or edit it.** CI (`.github/workflows/sync-headless.yml`) rebuilds it from `main` on every push, pruning GUI paths (`hypr waybar wofi kitty fcitx5 zed` + `misc/.config/{code-flags.conf,dolphinrc,mimeapps.list}`). Work on `main` only.
- **Don't edit `hypr/backup/`** — legacy config snapshots, not the active config.
- Deliberately not stowed/tracked: `~/.config/btop/btop.conf`, `~/.config/QtProject.conf` — both apps rewrite them at runtime; a symlink would cause endless noise diffs.

## Hyprland config (Lua, 0.55+)

Active config: `hypr/.config/hypr/hyprland.lua` + one module per concern (`modules/{monitors,env,look,input,binds,rules,autostart}.lua`).

All per-host differences (monitors, sensitivity, touchpad, env vars, screenshot key, extra binds) live **only** in `modules/machine.lua` as profiles: a `default` base plus named overrides (`archfw13`, `g36archpc`). Adding/porting a machine = flip `local current = ...` there (marked `>>> EDIT THIS LINE PER HOST <<<`) and, if needed, add a profile overriding only differing fields. Rest of the tree stays identical across hosts.

## Gotchas

- **Never stow without `--no-folding`.** Without it, if a target dir (e.g. `~/.pi`) doesn't exist yet, stow tree-folds it into one symlink into the repo — the app then writes its whole runtime state (pi: `npm/`, `sessions/`, `bin/`, caches; opencode: `opencode.db`, `storage/`) into the repo working tree. `--no-folding` keeps only file-level links; runtime state stays in real dirs under `$HOME`. (Flag still works on stow 2.4.1 although dropped from `--help`.)
- Keybinds reference runtime binaries (`hyprshot`, `playerctl`, `wpctl`, `brightnessctl`, …); missing binaries fail **silently** — key does nothing.
- `hypr/modules/binds.lua` binds `SUPER+N` twice; the center-window bind wins (later binding takes precedence).
- Screenshot key is profile-dependent (`F11` desktop, `PRINT` laptop) — read it from `machine.lua`, don't hardcode.
- `stow */` conflict = a real (non-symlink) file already exists at the target; move it to `~/.config-backup` first.

## No build/test/lint tooling

The only CI is the headless sync. After stowing a fresh machine, see README post-install steps: TPM clone for tmux (`Ctrl+b` prefix), zim self-bootstrap for zsh (needs `zimfw` package), `pi install npm:...` for pi packages, `opencode auth login` for provider keys.

Full package/deps documentation: `README.md` (canonical — keep it in sync when adding packages).
