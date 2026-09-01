# nvim setup

This is the Neovim config, it lives at `nvim/` and gets symlinked whole to
`~/.config/nvim`. It's built for daily work in TypeScript, Python, C/C++,
Rust, and C#, themed to match the rest of this repo, and kept deliberately
small. Thirteen plugins, each doing one job nothing else on the list does.
Nothing here turns Neovim into a terminal IDE with a dashboard and a
session manager and a dozen half-used extras, the whole point of reaching
for Neovim is that it stays fast.

## Install

```
ln -sf ~/dotfiles/nvim ~/.config/nvim
```

Launch `nvim` once and two things happen automatically. `lazy.nvim`
bootstraps itself and installs every plugin, then `mason.nvim` installs the
five language servers. The first launch takes a minute or two longer than
usual while that happens, every launch after is instant.

## Package manager

This uses `lazy.nvim`, the package manager, not LazyVim, the preconfigured
distro built on top of it. That distinction matters here: LazyVim ships its
own opinions and a much bigger default plugin set, which is exactly the
kind of accretion this config is trying to avoid. Everything in
`lua/plugins/` was written by hand for this setup, nothing was inherited
from a framework.

## Theme

Catppuccin Mocha, the same palette as Ghostty, tmux, and the zsh prompt
elsewhere in this repo, so Neovim doesn't look like a different app bolted
onto the terminal. `lualine` also picks up the Catppuccin theme for the
statusline.

## Language support

TypeScript, Python, C/C++, Rust, and C# each get a language server through
`mason.nvim` and `nvim-lspconfig`, completion through `blink.cmp`, and
formatting through `conform.nvim`. Python additionally gets linted with
`ruff` via `nvim-lint`, since pyright doesn't lint on its own.

| Language | LSP | Formatter |
|---|---|---|
| TypeScript/JS | `vtsls` | `prettier` |
| Python | `pyright` (+ `ruff` for lint) | `ruff_format` |
| C/C++ | `clangd` | `clang-format` |
| Rust | `rust_analyzer` | `rustfmt` |
| C# | `omnisharp` | `csharpier` |

`rust_analyzer` is plain here, no `rustaceanvim` layered on top yet. If the
built-in experience ever feels thin for Rust work, that's the first thing
worth adding.

## Completion

`blink.cmp` uses its `default` keymap preset, which binds both `<C-n>` /
`<C-p>` and the arrow keys to move through the suggestion list, so the
vim-native muscle memory from built-in omni-completion still works, arrow
keys are never required. `<C-space>` opens or closes the menu, `<Tab>` /
`<S-Tab>` jump through snippet placeholders, and accepting a function
completion auto-inserts the parens and drops the cursor inside them.

## Fuzzy finding

`fzf-lua` handles files, live grep, buffers, and LSP references, chosen
over `telescope.nvim` on purpose. It shells out to the `fzf` binary you
already have installed, which keeps it fast even in a big repo, and it
covers everything needed here without the chain of extension plugins
telescope tends to accumulate.

## Tree-sitter

Pinned to the `master` branch rather than `main`. The `nvim-treesitter`
project rewrote itself on `main`, and that branch currently needs Neovim
0.12, which is still nightly. `master` is frozen and only kept around for
backward compatibility, but it's the branch that actually works with the
0.11 line this config targets. Expect to move to `main` once 0.12 ships
stable.

## Keymaps

Leader is space.

| Keys | Action |
|---|---|
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` | list buffers |
| `<leader>fh` | search help tags |
| `<leader>fo` | recent files |
| `gr` | LSP references |
| `gd` | go to definition |
| `K` | hover docs |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action |
| `[d` / `]d` | previous/next diagnostic |
| `<leader>e` | toggle file tree |
| `<leader>f` | format buffer |
| `<leader>w` | save |
| `<leader>q` | quit |
| `<C-h/j/k/l>` | move between windows, crossing into tmux panes at the edge |

Format-on-save is also on by default, `<leader>f` is there for a manual
format when you want one mid-edit.

## Tmux integration

`tmux/.tmux.conf` already forwards `C-h/j/k/l` straight into whatever pane
is running vim or Neovim instead of switching tmux panes with those keys,
see its own README for that half. `vim-tmux-navigator` is the other half,
it moves between splits the same way `<C-w>h/j/k/l` would, but falls
through to an actual tmux pane switch once there's no more split to move
into. Without it those keys would just hit a dead end at the edge of the
Neovim window instead of crossing back out to tmux.

## Plugins in use

| Plugin | What it's for |
|---|---|
| `lazy.nvim` | package manager |
| `catppuccin/nvim` | colorscheme |
| `nvim-treesitter` | parsing and highlighting |
| `nvim-lspconfig` + `mason.nvim` + `mason-lspconfig.nvim` | language servers |
| `blink.cmp` | completion |
| `conform.nvim` + `nvim-lint` | formatting and linting |
| `fzf-lua` | fuzzy finding |
| `lualine.nvim` | statusline |
| `neo-tree.nvim` | file tree |
| `gitsigns.nvim` | git gutter signs and hunk actions |
| `nvim-autopairs` | auto-close brackets and quotes |
| `vim-tmux-navigator` | crosses `<C-h/j/k/l>` from Neovim splits into tmux panes |

## Prerequisites

`git`, a C compiler, `ripgrep`, and `fzf` all need to already be on `PATH`,
the C compiler is for building tree-sitter parsers and the other two are
what `fzf-lua` shells out to. A Nerd Font is expected too, for the icons in
`neo-tree` and `lualine`, Ghostty is already set to one elsewhere in this
repo.
