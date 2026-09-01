# tmux setup

This is the tmux config used across our machines. It lives at `tmux/.tmux.conf`
and gets symlinked to `~/.tmux.conf`. Read this once and the keybindings will
stick fast, most of them map to muscle memory you probably already have from
vim.

## Install

```
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Start tmux, then press `prefix + I` to fetch the plugins. That's the only
manual step. Everything else is already wired up in the config.

## The prefix

The prefix is `C-a`, not the tmux default `C-b`. It's one key on the home row
instead of a stretch, and it matches what a lot of people already have muscle
memory for from screen. Every binding below is either pressed after the
prefix or, for pane navigation, needs no prefix at all.

## Windows and panes

| Keys | Action |
|---|---|
| `prefix c` | new window, opens in the current directory |
| `prefix \|` | split pane vertically (side by side), opens in current directory |
| `prefix -` | split pane horizontally (stacked), opens in current directory |
| `prefix r` | reload the config without restarting the session |

The default split bindings (`"` and `%`) are unbound on purpose so muscle
memory doesn't fight between the old and new ones.

## Moving between panes

This is the part people notice first. `C-h` / `C-j` / `C-k` / `C-l` move you
between panes with no prefix needed, and if the active pane is running vim or
neovim, the same keys move between vim splits instead. You never have to
think about whether you're inside vim or inside a tmux pane, the keys just
do the right thing. This only works if your vim/neovim config also binds
`C-h/j/k/l` to window navigation, most setups already do.

Resizing panes:

| Keys | Action |
|---|---|
| `prefix H` | resize left |
| `prefix J` | resize down |
| `prefix K` | resize up |
| `prefix L` | resize right |

Hold the letter and it keeps resizing, no need to hit prefix each time.

## Copy mode

Copy mode uses vi-style keys instead of the emacs-style defaults.

| Keys | Action |
|---|---|
| `prefix [` | enter copy mode |
| `v` | start a selection |
| `C-v` | switch to a rectangular (block) selection |
| `y` | copy the selection and exit copy mode |
| `Escape` | cancel |

Anything you copy in tmux goes straight to the system clipboard through
`tmux-yank`, no separate `pbcopy`/`xclip` step required.

## Mouse

Mouse mode is on. Click a pane to focus it, drag a border to resize, scroll
to look at history, click and drag to select text for copying. This can be
turned off with `set -g mouse off` if you'd rather stay keyboard only.

## Session persistence

Two plugins handle this together: `tmux-resurrect` and `tmux-continuum`.

- `prefix C-s` saves the current state of every session, window, and pane
- `prefix C-r` restores the last saved state
- continuum also autosaves in the background every few minutes, and restores
  automatically on tmux start, so a reboot or a crashed terminal doesn't cost
  you your layout

Pane contents (scrollback) get captured too, so a restored pane shows what
was on screen before, not just an empty shell.

## Status bar

Kept plain: session name on the left, current date and time on the right,
window list in the middle with the active window bolded. Nothing fancy,
nothing that needs a font patch.

## Plugins in use

| Plugin | What it's for |
|---|---|
| `tpm` | the plugin manager itself |
| `tmux-sensible` | a baseline of settings most people agree on |
| `tmux-yank` | copy mode selections go to the system clipboard |
| `tmux-resurrect` | manual save/restore of sessions |
| `tmux-continuum` | automatic background save and restore on top of resurrect |

`prefix I` installs plugins, `prefix U` updates them, `prefix alt-u`
removes ones no longer listed in the config.

## Other defaults worth knowing

- windows and panes are numbered starting at 1, not 0, so the number keys on
  your keyboard line up with the window numbers shown in the status bar
- closing a window renumbers the rest automatically, no gaps
- scrollback history is bumped to 50000 lines
- escape time is set to 0, which matters if you use vim/neovim inside tmux,
  otherwise there's a noticeable lag after pressing Escape
- terminal is set up for true color so colorschemes in vim/neovim and CLI
  tools render correctly instead of looking washed out
