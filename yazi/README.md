# yazi setup

Yazi is the terminal file manager, config lives at `yazi/yazi.toml` and
`yazi/theme.toml`, both symlinked into `~/.config/yazi/`. It's intentionally
thin, yazi's own defaults are already good, this just points the color
theme at Catppuccin Mocha and tweaks a couple of sorting defaults.

## Install

Yazi isn't packaged for this distro, it's installed as a prebuilt binary:

```
curl -fsSL -o /tmp/yazi.zip https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
unzip -oq /tmp/yazi.zip -d /tmp/yazi-extracted
cp /tmp/yazi-extracted/*/yazi /tmp/yazi-extracted/*/ya ~/.local/bin/
```

Then symlink the config and pull down the theme package:

```
ln -sf ~/dotfiles/yazi/yazi.toml ~/.config/yazi/yazi.toml
ln -sf ~/dotfiles/yazi/theme.toml ~/.config/yazi/theme.toml
ln -sf ~/dotfiles/yazi/package.toml ~/.config/yazi/package.toml
ya pkg install
```

`package.toml` just records which flavor package is in use (Catppuccin
Mocha), `ya pkg install` reads it and fetches the actual theme files into
`~/.config/yazi/flavors/`, which don't get committed since they're fetched
content, same idea as a lockfile versus `node_modules`.

## fd and bat, for real this time

Yazi shells out to `fd` and `bat` directly as subprocesses for search and
file preview. The zsh aliases for those (`fd` → `fdfind`, `bat` → `batcat`)
only apply inside an interactive shell, a program launching the binary
itself never sees them. So there are two real symlinks in `~/.local/bin`
making the actual binary names work everywhere, not just in zsh:

```
ln -sf /usr/bin/fdfind ~/.local/bin/fd
ln -sf /usr/bin/batcat ~/.local/bin/bat
```

Worth knowing if some other tool you add later also expects `fd` or `bat`
by name, it'll just work now.

## Using it

Launch it with `y`, not `yazi` directly. That's a shell function in
`zsh/.zshrc`, not an alias, because it needs to run a command after yazi
exits: it hands yazi a temp file to write its last directory into, then
`cd`s your shell there. Plain `yazi` opens and closes fine but leaves you
back where you started.

| Keys | Action |
|---|---|
| `y` | open yazi, `cd`s your shell into wherever you ended up browsing |
| `q` | quit and `cd` into the last directory |
| `Q` | quit without changing the shell's directory |
| `h` / `j` / `k` / `l` | left / down / up / right, same as vim |
| `Enter` | open the selected file or enter the directory |
| `Space` | select the item under the cursor, for acting on multiple files |
| `y` then `p` | yank (copy) then paste, `x` then `p` cuts then paste |
| `d` | delete the selection, `a` creates a new file or directory |
| `Tab` | preview pane / task list toggle depending on context |
| `/` | search by name in the current directory |

Everything else is yazi's own defaults, which are already vim-shaped and
don't need much explaining once you've used it for five minutes.
