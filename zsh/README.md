# zsh setup

This is the shell config, it lives at `zsh/.zshrc` and gets symlinked to
`~/.zshrc`. Paired with `starship/starship.toml` for the prompt. Read
through once and most of it will feel familiar within a day of use.

## Install

```
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml
chsh -s $(which zsh)
```

The plugin manager, zinit, installs itself. The first time you open a new
shell it clones itself and the three plugins listed below, that one-time
setup takes a few seconds and shows a progress bar. Every shell after that
starts instantly from cache.

You'll also want these installed system-wide, most are one `apt install`
away:

```
sudo apt install zsh starship fzf zoxide eza bat ripgrep fd-find
```

Two of those get renamed by Debian/Ubuntu's packaging to avoid clashing
with older tools already using the name: `bat` installs as `batcat`, and
`fd-find` installs as `fdfind`. The config aliases both back to their
normal names, so you just type `bat` and `fd` and never notice.

## Icons

Both the prompt and `eza`'s file listings use icon glyphs that come from a
Nerd Font, a regular font won't have them. Ghostty is set to
`JetBrainsMono Nerd Font Mono`, if you're on a different terminal, point
its font setting at the same one or the icons will show as boxes.

Install it with:

```
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
curl -fsSL -o /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -oq /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont "*.ttf"
fc-cache -f ~/.local/share/fonts
```

## Plugins

| Plugin | What it does |
|---|---|
| `zsh-completions` | extra completion definitions for a long list of CLI tools |
| `zsh-autosuggestions` | shows a greyed-out completion of a past command as you type, right arrow or `end` accepts it |
| `zsh-syntax-highlighting` | colors commands as you type, green means it resolves to something real, red means it doesn't |

`zinit self-update` updates zinit itself, `zinit update` pulls the latest
version of every plugin.

## The prompt

Comes from starship, not zsh itself, so it's fast and looks the same
whether you're in bash, zsh, or fish. It shows, left to right: the current
directory (truncated to the last few segments, shortened further inside a
git repo), the git branch and status if you're in one, and a colored arrow
that turns red after a command exits non-zero. A command taking longer
than 2 seconds gets a "took Xs" note. If you're in a project with node,
go, rust, or python, the relevant runtime version shows up too.

## Fuzzy search and jumping around

fzf and zoxide are the two habits worth building first.

| Keys | What happens |
|---|---|
| `ctrl+r` | fuzzy search your shell history |
| `ctrl+t` | fuzzy find a file and drop its path at the cursor |
| `alt+c` | fuzzy find a directory and cd into it |

`z <part of a name>` jumps to a directory you've visited before, it learns
from your `cd` history so the more you use it the better it gets at
guessing where you meant. `zi` does the same thing but shows a fuzzy list
to pick from instead of guessing.

## Core tool replacements

| Old command | Runs instead | Why |
|---|---|---|
| `ls` / `ll` / `la` / `lt` | `eza` | icons, git status per file, colors, a proper `--tree` mode |
| `cat` | `bat` | syntax highlighting, line numbers |
| `grep` | `ripgrep` | much faster, respects `.gitignore` by default |
| `find` | `fd` | simpler syntax, faster, also respects `.gitignore` |

If you ever need the real, unaliased version of one of these, either
prefix it with a backslash (`\ls`) or call the binary directly
(`/bin/ls`, `batcat`, `fdfind`).

## History

History is shared live across every open shell, 50000 lines deep,
duplicates are skipped, and a leading space keeps a command out of history
entirely for anything you'd rather not have logged.

## Other defaults worth knowing

- `AUTO_CD` means typing a directory name on its own, no `cd` needed, moves
  you into it
- globbing is case-insensitive and sorts numbers the way you'd expect
  (`file2` before `file10`)
- everything from the old `.bashrc` that actually did something (fnm, Go
  and cargo paths, the `dev`/`claude`/`fix-mounts` aliases) got carried
  over, nothing was silently dropped
