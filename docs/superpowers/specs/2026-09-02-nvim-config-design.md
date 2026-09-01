# Neovim config — design

## Purpose

Add a Neovim configuration to this dotfiles repo, following the same
pattern as the other tool directories (`ghostty/`, `tmux/`, `zsh/`,
`starship/`, `yazi/`): a self-contained directory, symlinked into
place, documented in the top-level README and its own `nvim/README.md`.

## Constraints (from the user)

- Languages to support well: TypeScript, Python, C/C++, Rust (growing
  priority), and C# (work).
- Theme: Catppuccin Mocha, matching ghostty/tmux/starship/zsh already
  in this repo.
- Package manager: `lazy.nvim` — the package manager itself, **not**
  the LazyVim distro. No preconfigured opinionated framework.
- Fuzzy finder: pick the better of `telescope.nvim` vs `fzf-lua`.
  Decision: `fzf-lua`, because it shells out to the `fzf` binary for
  matching (fast, no native-build step) and covers files/grep/
  buffers/LSP pickers/git without pulling in a chain of extension
  plugins the way telescope tends to (telescope-fzf-native,
  telescope-ui-select, etc.).
- `nvim-treesitter` is mandatory.
- Hard requirement: stay minimal. The user has been burned before by
  configs that accreted "3 billion plugins" and became slow and
  chaotic. If the plan ever drifts toward turning Neovim into a
  terminal VS Code, that's a signal to stop and cut back, not a
  feature to add.

## Non-goals

- Not building a general-purpose "distro" or something meant to be
  reused by others — this is one person's config, tuned to their
  stack.
- Not chasing plugin-for-every-feature completeness (no which-key, no
  dashboard/greeter, no session manager, no tabline plugin, no
  autopairs, no comment plugin — commenting is native in modern nvim).
- Not attempting multi-machine OS abstraction beyond what the rest of
  the repo already does (symlink install, README documents any
  system-level prerequisites like the `fzf` binary or a C compiler for
  treesitter parsers).

## Plugin list (11 plugins total)

| Plugin | Job |
|---|---|
| `lazy.nvim` | package manager (bootstrap only, not a config framework) |
| `catppuccin/nvim` (mocha flavor) | colorscheme |
| `nvim-treesitter` | parsing/highlighting: `typescript`, `tsx`, `python`, `c`, `cpp`, `rust`, `c_sharp`, `lua`, `bash`, `markdown`, `vim`, `vimdoc`, `query` |
| `nvim-lspconfig` | LSP client configuration |
| `mason.nvim` + `mason-lspconfig.nvim` | auto-install/manage LSP servers per machine |
| `blink.cmp` | completion engine (LSP, path, snippets) — no separate snippet engine plugin needed, blink has its own |
| `conform.nvim` | format-on-save |
| `nvim-lint` | linting where the LSP doesn't provide it (ruff) |
| `fzf-lua` | fuzzy finder (files, grep, buffers, LSP pickers, git) |
| `lualine.nvim` | statusline |
| `neo-tree.nvim` (+ `plenary.nvim`, `nui.nvim`, `nvim-web-devicons` as its direct deps) | file tree |
| `gitsigns.nvim` | gutter diff signs, hunk stage/undo, blame |

Everything above was chosen because it does a job nothing else on the
list does. No plugin is included "because it's popular" or "just in
case."

## Language servers (installed via mason)

| Language | Server | Notes |
|---|---|---|
| TypeScript/JS | `vtsls` | more actively maintained fork of `ts_ls` |
| Python | `pyright` + `ruff` | pyright for types, ruff for lint + format (via conform/nvim-lint) — much faster than black+flake8 |
| C/C++ | `clangd` | |
| Rust | `rust_analyzer` | plain, via lspconfig/mason. `rustaceanvim` (richer cargo/runnable integration) is a deliberate future option, not included now — start lean, add only if plain rust_analyzer proves thin given Rust is a growing priority |
| C# | `omnisharp` | most feature-complete mason-installable option; slower to boot than `csharp-ls` but has working find-references/rename on real solutions, which matters more for work code than startup speed |

## Formatters (via conform.nvim, format-on-save)

- TypeScript/JS: `prettier`
- Python: `ruff_format`
- C/C++: `clang-format`
- Rust: `rustfmt`
- C#: `csharpier`

## File layout

```
nvim/
  init.lua                  -- entry point, requires everything below
  lua/config/options.lua    -- vim.opt settings
  lua/config/keymaps.lua    -- keymaps not owned by a specific plugin
  lua/config/autocmds.lua   -- autocommands not owned by a specific plugin
  lua/config/lazy.lua       -- bootstraps lazy.nvim, imports lua/plugins/
  lua/plugins/
    colorscheme.lua        -- catppuccin
    treesitter.lua
    lsp.lua                -- lspconfig + mason + mason-lspconfig
    completion.lua         -- blink.cmp
    format.lua             -- conform.nvim + nvim-lint
    finder.lua             -- fzf-lua
    ui.lua                 -- lualine, neo-tree, gitsigns
  README.md                 -- matches the style of the repo's other tool READMEs
```

Each `lua/plugins/*.lua` file returns a lazy.nvim plugin spec table (or
list of tables) for one plugin/tightly-related group — lazy.nvim
auto-imports every file in `lua/plugins/`. This keeps `init.lua` and
`lua/config/lazy.lua` tiny and keeps each concern in its own small
file, per the repo's existing style of small, focused config files.

## Install / integration with the rest of the repo

- Symlink: `ln -sf ~/dotfiles/nvim ~/.config/nvim`
- Add a row to the top-level README's tool table and an entry in the
  install block, matching the existing pattern.
- `nvim/README.md` documents: what's installed, why each plugin is
  there, system prerequisites (a C compiler for treesitter parsers,
  the `fzf` binary, `git`, `ripgrep` for grep-based pickers, a
  Nerd Font — already covered by the existing ghostty setup), and any
  first-run steps (lazy.nvim bootstraps itself on first launch; mason
  installs LSP servers on first launch of `:Lazy sync` / via
  `mason-lspconfig`'s `ensure_installed`).
- Neovim itself is not currently installed on this machine; installing
  it is part of implementation so the config can actually be run and
  verified, not just written.

## Testing / verification

- Install Neovim (a recent stable release — targeting 0.10+ for
  current LSP/treesitter APIs).
- Launch nvim against the new config, confirm lazy.nvim bootstraps and
  installs all plugins without error.
- Open a file in each target language (ts/tsx, py, c, cpp, rs, cs) in
  a scratch project, confirm: treesitter highlighting active, LSP
  attaches (hover/go-to-definition/diagnostics work), completion
  triggers, format-on-save runs, fzf-lua pickers open and function,
  neo-tree opens, lualine renders, gitsigns shows changes in a git
  repo.
- Confirm startup time stays fast (`nvim --startuptime`) — this is a
  direct check against the stated goal of avoiding a sluggish config.
