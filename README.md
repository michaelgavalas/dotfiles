# dotfiles

Config files for the tools I use daily, kept in one place and symlinked
into position on each machine. Clone it, run the symlink commands below,
and a new box is caught up in a couple minutes.

## What's in here

| Directory | Tool | Notes |
|---|---|---|
| `ghostty/` | Ghostty terminal | font, keybinds, ssh terminfo handling |
| `tmux/` | tmux | full keybinding and plugin setup, see its own README |

## Install

```
git clone https://github.com/michaelgavalas/dotfiles.git ~/dotfiles

ln -sf ~/dotfiles/ghostty/config.ghostty ~/.config/ghostty/config.ghostty
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
```

tmux also needs its plugin manager cloned once:

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then start tmux and press `prefix + I` to pull the plugins down. Full
details, including every keybinding, are in `tmux/README.md`.

## Ghostty

Font is JetBrains Mono with ligatures on, cursor is a static block (no
blink), and window padding is bumped up a bit for readability. Clipboard
keybinds are `ctrl+shift+c` / `ctrl+shift+v` since Ghostty already uses
plain `ctrl+c` for its usual job inside a shell.

The config also turns on `shell-integration-features = ssh-terminfo`,
which installs Ghostty's terminfo entry on a remote host automatically the
first time you SSH into it. Without this, tools like vim or htop fail on a
fresh remote with `unknown terminal type: xterm-ghostty`, since most
servers don't ship Ghostty's terminfo entry by default. With it on,
Ghostty handles the install itself and caches which hosts already have it,
no manual `infocmp | tic` dance required.

## tmux

Prefix is `C-a`, panes move with `C-h/j/k/l` and stay aware of vim splits,
copy mode uses vi keys and pushes straight to the system clipboard, and
sessions autosave/restore across reboots. All of it, plus the reasoning
behind each choice, is written up in `tmux/README.md`.

## Adding something new

Give the tool its own directory, drop the config file in, symlink it into
place from your home directory the same way the two above are done, and
add a row to the table at the top of this file.
