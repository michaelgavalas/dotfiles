# Neovim Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a minimal, fast Neovim config to this dotfiles repo covering TypeScript, Python, C/C++, Rust, and C#, themed Catppuccin Mocha to match the rest of the repo.

**Architecture:** `lazy.nvim` as the bare package manager (not the LazyVim distro) loading a small `init.lua` that requires hand-written option/keymap/autocmd modules plus one file per plugin under `lua/plugins/`, which lazy.nvim auto-imports. Eleven plugins total, each doing one job nothing else on the list does.

**Tech Stack:** Neovim 0.11+, Lua, lazy.nvim, catppuccin/nvim, nvim-treesitter (master branch), nvim-lspconfig + mason.nvim + mason-lspconfig.nvim, blink.cmp, conform.nvim, nvim-lint, fzf-lua, lualine.nvim, neo-tree.nvim, gitsigns.nvim.

**Spec:** `docs/superpowers/specs/2026-09-02-nvim-config-design.md`

## Global Constraints

- Stay minimal. Eleven plugins, no more, unless a real gap shows up during testing (not "might be nice").
- This is `lazy.nvim` the package manager. Do not add LazyVim or any preconfigured distro.
- Fuzzy finder is `fzf-lua`, not telescope.
- `nvim-treesitter` is mandatory and must actually be verified working (parser installed, highlighting active), not just declared in a plugin spec.
- Theme is Catppuccin Mocha everywhere it applies (colorscheme, lualine theme).
- Target Neovim 0.11+ API: use `vim.lsp.config()` / `vim.lsp.enable()`, not the deprecated `require('lspconfig')[server].setup()` pattern.
- `nvim-treesitter` must pin `branch = "master"` (not `main`) — `main` requires Neovim 0.12 (nightly), which is newer than the 0.11.6 this plan installs via apt. `master` is frozen/deprecated upstream but is the only branch that supports 0.11.
- README prose (both `nvim/README.md` and the top-level README edit) must never use em dashes and must vary sentence structure sentence-to-sentence, matching the existing style in `tmux/README.md` and `zsh/README.md`.
- No plugin gets added "because it's popular." Every addition must trace to a spec requirement.

---

### Task 1: Install Neovim and verify prerequisites

**Files:** none (system setup only)

**Interfaces:**
- Consumes: nothing
- Produces: a working `nvim` binary (0.11.6 via apt) and confirmed presence of `git`, `ripgrep` (`rg`), `fzf`, and a C compiler (`cc`) on `PATH` — every later task assumes these exist.

- [ ] **Step 1: Install Neovim via apt**

Run: `sudo apt-get update && sudo apt-get install -y neovim`

- [ ] **Step 2: Verify Neovim and prerequisite tools are present**

Run:
```bash
nvim --version | head -1
git --version
rg --version | head -1
fzf --version
cc --version | head -1
```
Expected: all five print a version string with no "command not found" errors. Neovim should report `0.11.x` or newer.

- [ ] **Step 3: Commit**

Nothing to commit (system-level install, no repo files changed). Move directly to Task 2.

---

### Task 2: Scaffold core config and lazy.nvim bootstrap

**Files:**
- Create: `nvim/init.lua`
- Create: `nvim/lua/config/options.lua`
- Create: `nvim/lua/config/keymaps.lua`
- Create: `nvim/lua/config/autocmds.lua`
- Create: `nvim/lua/config/lazy.lua`

**Interfaces:**
- Consumes: nothing
- Produces: a `lua/plugins/` auto-import convention (any `.lua` file dropped in `nvim/lua/plugins/` that returns a lazy.nvim spec table gets picked up automatically) — every later task relies on this.

- [ ] **Step 1: Write `nvim/lua/config/options.lua`**

```lua
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.updatetime = 250
opt.undofile = true
opt.wrap = false
```

- [ ] **Step 2: Write `nvim/lua/config/keymaps.lua`**

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
```

- [ ] **Step 3: Write `nvim/lua/config/autocmds.lua`**

```lua
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank()
  end,
})
```

- [ ] **Step 4: Write `nvim/lua/config/lazy.lua`**

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "default" } },
  checker = { enabled = false },
})
```

- [ ] **Step 5: Write `nvim/init.lua`**

```lua
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
```

- [ ] **Step 6: Verify the config loads with no plugins yet and no errors**

Run: `nvim --headless -u nvim/init.lua -c "qa" 2>&1; echo "exit: $?"`
Expected: lazy.nvim clones itself (one-time network fetch), no Lua tracebacks printed, `exit: 0`.

- [ ] **Step 7: Commit**

```bash
git add nvim/init.lua nvim/lua
git commit -m "$(cat <<'EOF'
Scaffold nvim config skeleton and lazy.nvim bootstrap

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 3: Colorscheme (Catppuccin Mocha)

**Files:**
- Create: `nvim/lua/plugins/colorscheme.lua`

**Interfaces:**
- Consumes: the `lua/plugins/` auto-import convention from Task 2
- Produces: the active colorscheme is `"catppuccin"` — Task 9's lualine config reads `theme = "catppuccin"` and assumes this plugin already set the colorscheme.

- [ ] **Step 1: Write `nvim/lua/plugins/colorscheme.lua`**

```lua
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "mocha",
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
```

- [ ] **Step 2: Verify the colorscheme applies with no errors**

Run:
```bash
nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "lua io.write(vim.g.colors_name or 'NONE')" -c "qa" 2>&1
```
Expected: first command installs `catppuccin/nvim` with no errors; second command prints `catppuccin`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/colorscheme.lua
git commit -m "$(cat <<'EOF'
Add Catppuccin Mocha colorscheme

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 4: Tree-sitter

**Files:**
- Create: `nvim/lua/plugins/treesitter.lua`

**Interfaces:**
- Consumes: the `lua/plugins/` auto-import convention from Task 2
- Produces: parsers installed and highlighting enabled for `typescript, tsx, python, c, cpp, rust, c_sharp, lua, bash, markdown, markdown_inline, vim, vimdoc, query` — Task 12's integration check opens files in each of these filetypes and expects highlighting to be active.

**Note:** pin `branch = "master"`, not `main`. `main` is the rewritten branch and currently requires Neovim 0.12 (nightly); `master` is the frozen-but-still-0.11-compatible branch and is the only one that works with the 0.11.6 installed in Task 1.

- [ ] **Step 1: Write `nvim/lua/plugins/treesitter.lua`**

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "typescript", "tsx", "python", "c", "cpp", "rust", "c_sharp",
        "lua", "bash", "markdown", "markdown_inline", "vim", "vimdoc", "query",
      },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
```

- [ ] **Step 2: Verify parsers install and highlighting activates**

Run:
```bash
nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "TSInstallSync! typescript tsx python c cpp rust c_sharp lua bash markdown markdown_inline vim vimdoc query" -c "qa" 2>&1

mkdir -p /tmp/nvim-config-check
printf 'fn main() {\n    println!("hi");\n}\n' > /tmp/nvim-config-check/sample.rs
nvim --headless -u nvim/init.lua /tmp/nvim-config-check/sample.rs \
  -c "lua print('highlighter active: ' .. tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil))" \
  -c "qa" 2>&1
```
Expected: install commands complete with no errors, and the final command prints `highlighter active: true`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/treesitter.lua
git commit -m "$(cat <<'EOF'
Add tree-sitter with parsers for all target languages

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 5: Completion (blink.cmp)

**Files:**
- Create: `nvim/lua/plugins/completion.lua`

**Interfaces:**
- Consumes: the `lua/plugins/` auto-import convention from Task 2
- Produces: `require("blink.cmp").get_lsp_capabilities()` — Task 6's LSP config calls this to build the capabilities table it hands every language server.

- [ ] **Step 1: Write `nvim/lua/plugins/completion.lua`**

```lua
return {
  "saghen/blink.cmp",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "1.*",
  event = "InsertEnter",
  opts = {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    completion = { documentation = { auto_show = true } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
```

- [ ] **Step 2: Verify the plugin installs and loads with no errors**

Run:
```bash
nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "lua print('capabilities: ' .. tostring(require('blink.cmp').get_lsp_capabilities() ~= nil))" -c "qa" 2>&1
```
Expected: install completes with no errors; second command prints `capabilities: true`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/completion.lua
git commit -m "$(cat <<'EOF'
Add blink.cmp for LSP/path/snippet completion

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 6: LSP (mason + mason-lspconfig + nvim-lspconfig)

**Files:**
- Create: `nvim/lua/plugins/lsp.lua`

**Interfaces:**
- Consumes: `require("blink.cmp").get_lsp_capabilities()` from Task 5
- Produces: attached LSP clients per filetype (`vtsls` for ts/tsx, `pyright`+`ruff` for python, `clangd` for c/cpp, `rust_analyzer` for rust, `omnisharp` for cs) — Task 12's integration check opens a file per language and checks `vim.lsp.get_clients({bufnr=0})` for the expected client name.

**Note:** use the Neovim 0.11+ `vim.lsp.config()` / `vim.lsp.enable()` API, not the deprecated `require('lspconfig')[server].setup()` pattern. `mason-lspconfig.nvim` auto-calls `vim.lsp.enable()` for everything in `ensure_installed`, so this file only needs to set shared defaults (capabilities) and the keymaps, and let `mason-lspconfig` do the enabling.

- [ ] **Step 1: Write `nvim/lua/plugins/lsp.lua`**

```lua
return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim" },
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    opts = {
      ensure_installed = { "vtsls", "pyright", "ruff", "clangd", "rust_analyzer", "omnisharp" },
    },
    config = function(_, opts)
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map_opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, map_opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, map_opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, map_opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, map_opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, map_opts)
        end,
      })

      require("mason-lspconfig").setup(opts)
    end,
  },
}
```

- [ ] **Step 2: Verify all five servers install**

Run:
```bash
nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "MasonInstall vtsls pyright ruff clangd rust-analyzer omnisharp" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "lua print(vim.inspect(require('mason-registry').get_installed_package_names()))" -c "qa" 2>&1
```
Expected: the install command completes (may take a few minutes, omnisharp and clangd are large downloads), and the final command's output list includes `vtsls`, `pyright`, `ruff`, `clangd`, `rust-analyzer`, and `omnisharp`.

- [ ] **Step 3: Verify a server attaches to a real buffer**

```bash
printf 'fn main() {}\n' > /tmp/nvim-config-check/sample.rs
nvim --headless -u nvim/init.lua /tmp/nvim-config-check/sample.rs \
  -c "sleep 3" \
  -c "lua local n={} for _,c in ipairs(vim.lsp.get_clients({bufnr=0})) do table.insert(n,c.name) end print('clients: '..table.concat(n,','))" \
  -c "qa" 2>&1
```
Expected: prints `clients: rust_analyzer`.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/plugins/lsp.lua
git commit -m "$(cat <<'EOF'
Add LSP setup for TypeScript, Python, C/C++, Rust, and C#

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 7: Format and lint (conform.nvim + nvim-lint)

**Files:**
- Create: `nvim/lua/plugins/format.lua`

**Interfaces:**
- Consumes: the `lua/plugins/` auto-import convention from Task 2
- Produces: `<leader>f` (manual format) and format-on-save via `conform.nvim`; automatic `ruff` linting via `nvim-lint` on write/read/insert-leave. Nothing later depends on this file's internals.

- [ ] **Step 1: Write `nvim/lua/plugins/format.lua`**

```lua
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        python = { "ruff_format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        rust = { "rustfmt" },
        cs = { "csharpier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
```

- [ ] **Step 2: Verify both plugins load and the formatter list resolves**

Run:
```bash
nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "lua print(vim.inspect(require('conform').list_all_formatters and 'loaded' or 'MISSING'))" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "lua print('lint loaded: ' .. tostring(require('lint') ~= nil))" -c "qa" 2>&1
```
Expected: no errors; second command prints `loaded`; third prints `lint loaded: true`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/format.lua
git commit -m "$(cat <<'EOF'
Add format-on-save and linting

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 8: Fuzzy finder (fzf-lua)

**Files:**
- Create: `nvim/lua/plugins/finder.lua`

**Interfaces:**
- Consumes: the `lua/plugins/` auto-import convention from Task 2
- Produces: `<leader>ff/fg/fb/fh/fo` and `gr` keymaps. `gr` here is the only place LSP references is bound (Task 6 deliberately does not bind `gr`, to avoid a duplicate/conflicting mapping).

- [ ] **Step 1: Write `nvim/lua/plugins/finder.lua`**

```lua
return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
    { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    { "gr", "<cmd>FzfLua lsp_references<cr>", desc = "LSP references" },
  },
  opts = {},
}
```

- [ ] **Step 2: Verify the plugin installs and the command exists**

Run:
```bash
nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "lua print('fzf-lua loaded: ' .. tostring(pcall(require, 'fzf-lua')))" -c "qa" 2>&1
```
Expected: no errors; prints `fzf-lua loaded: true`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/finder.lua
git commit -m "$(cat <<'EOF'
Add fzf-lua for fuzzy finding

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 9: UI (lualine, neo-tree, gitsigns)

**Files:**
- Create: `nvim/lua/plugins/ui.lua`

**Interfaces:**
- Consumes: the `"catppuccin"` colorscheme name from Task 3 (lualine's `theme` option)
- Produces: `<leader>e` toggles the file tree. Nothing later depends on this file.

- [ ] **Step 1: Write `nvim/lua/plugins/ui.lua`**

```lua
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "catppuccin", globalstatus = true },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
```

- [ ] **Step 2: Verify all three plugins install and load with no errors**

Run:
```bash
nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1
nvim --headless -u nvim/init.lua -c "lua print('lualine: '..tostring(pcall(require,'lualine'))..' neo-tree: '..tostring(pcall(require,'neo-tree'))..' gitsigns: '..tostring(pcall(require,'gitsigns')))" -c "qa" 2>&1
```
Expected: no errors; prints `lualine: true neo-tree: true gitsigns: true`.

- [ ] **Step 3: Commit**

```bash
git add nvim/lua/plugins/ui.lua
git commit -m "$(cat <<'EOF'
Add statusline, file tree, and git gutter signs

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 10: `nvim/README.md`

**Files:**
- Create: `nvim/README.md`

**Interfaces:**
- Consumes: nothing
- Produces: nothing consumed by other tasks; this is documentation.

- [ ] **Step 1: Read the existing README style before writing**

Run: read `tmux/README.md` and `zsh/README.md` in full. Note the voice: direct, matter-of-fact, no em dashes, sentences of varying length (some short, some long with a comma clause), explains the *why* behind non-obvious choices rather than just listing settings.

- [ ] **Step 2: Write `nvim/README.md`**

Cover, in prose matching that style (short paragraphs, no bullet-only sections, no em dashes, no repeating the same sentence template twice in a row):
- What's in here at a glance: lazy.nvim as the package manager (explicitly not LazyVim), Catppuccin Mocha to match the rest of the repo, tree-sitter, LSP/completion/formatting for TypeScript, Python, C/C++, Rust, and C#, fzf-lua for fuzzy finding.
- Why fzf-lua over telescope (shells out to the `fzf` binary, stays fast, avoids the extension-plugin sprawl telescope tends to accumulate).
- Why nvim-treesitter is pinned to the `master` branch instead of `main` (the rewritten `main` branch currently needs Neovim 0.12/nightly; `master` still supports the 0.11 line this config targets, and is expected to move again once 0.12 is stable).
- The keymap rundown: `<leader>ff/fg/fb/fh/fo` (fzf-lua pickers), `gr` (LSP references via fzf-lua), `gd`/`K`/`<leader>rn`/`<leader>ca`/`[d`/`]d` (LSP), `<leader>e` (file tree), `<leader>f` (format buffer), `<leader>w`/`<leader>q` (save/quit), `<C-hjkl>` (window nav).
- System prerequisites: `git`, a C compiler (for tree-sitter parsers), `ripgrep` and `fzf` (for fzf-lua's file/grep pickers), a Nerd Font (already covered by the ghostty setup in this repo).
- First-run behavior: lazy.nvim bootstraps itself on first launch and installs every plugin; mason installs the five LSP servers the same way. First launch will take a minute or two longer than normal while that happens.
- Explicit statement of the minimalism intent: eleven plugins, chosen because each does a job nothing else on the list does, no which-key/dashboard/session-manager/autopairs, and the reasoning for staying lean (avoiding the "3 billion plugins" sluggishness this config is deliberately avoiding).

- [ ] **Step 3: Check for em dashes and repetitive sentence openers**

Run: `grep -n "—\|--" nvim/README.md`
Expected: no matches (aside from code blocks showing shell flags like `--filter`, which are fine). Re-read the file once for sentences that all start the same way (e.g. three sentences in a row starting with "This") and rewrite any you find.

- [ ] **Step 4: Commit**

```bash
git add nvim/README.md
git commit -m "$(cat <<'EOF'
Add nvim README

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 11: Update top-level README

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: nothing
- Produces: nothing consumed by other tasks.

- [ ] **Step 1: Add a row to the tool table**

In the table under "What's in here", add a row following the existing format:
```
| `nvim/` | Neovim | editor config, see its own README |
```

- [ ] **Step 2: Add the symlink command to the Install block**

In the fenced install command block, add:
```
ln -sf ~/dotfiles/nvim ~/.config/nvim
```

- [ ] **Step 3: Add a short "## Neovim" section**

Following the style of the existing "## Ghostty" / "## tmux" sections (a paragraph or two, no em dashes, no repeated sentence openers): note the theme, that it uses lazy.nvim (not LazyVim), the language coverage (TypeScript, Python, C/C++, Rust, C#), and that `nvim/README.md` has the full keymap and plugin rundown plus prerequisites.

- [ ] **Step 4: Check for em dashes**

Run: `grep -n "—" README.md`
Expected: no matches.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "$(cat <<'EOF'
Document nvim config in top-level README

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01KhkMdL5TEaqNqpkSRB8Qde
EOF
)"
```

---

### Task 12: Full integration verification

**Files:** none (verification only, no repo changes expected)

**Interfaces:**
- Consumes: the complete config from Tasks 2-9
- Produces: nothing; this is the final gate before calling the plan done.

- [ ] **Step 1: Confirm a clean full install with no errors**

Run: `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim && nvim --headless -u nvim/init.lua "+Lazy! sync" -c "qa" 2>&1`
Expected: every plugin installs from scratch with no error output. (This intentionally wipes any previous test state so the check reflects what a fresh machine would see.)

- [ ] **Step 2: Create one scratch file per target language**

```bash
mkdir -p /tmp/nvim-config-check
printf 'const x: number = 1;\nexport function add(a: number, b: number): number {\n  return a + b;\n}\n' > /tmp/nvim-config-check/sample.ts
printf 'def add(a: int, b: int) -> int:\n    return a + b\n' > /tmp/nvim-config-check/sample.py
printf '#include <stdio.h>\nint main(void) { printf("hi"); return 0; }\n' > /tmp/nvim-config-check/sample.c
printf '#include <iostream>\nint main() { std::cout << "hi"; return 0; }\n' > /tmp/nvim-config-check/sample.cpp
printf 'fn main() {\n    println!("hi");\n}\n' > /tmp/nvim-config-check/sample.rs
printf 'class Program {\n    static void Main() { System.Console.WriteLine("hi"); }\n}\n' > /tmp/nvim-config-check/sample.cs
```

- [ ] **Step 3: Confirm the right LSP client attaches for each file**

Run, for each `(file, expected_client)` pair `(sample.ts, vtsls)`, `(sample.py, pyright)`, `(sample.c, clangd)`, `(sample.cpp, clangd)`, `(sample.rs, rust_analyzer)`, `(sample.cs, omnisharp)`:
```bash
nvim --headless -u nvim/init.lua /tmp/nvim-config-check/<file> \
  -c "sleep 3" \
  -c "lua local n={} for _,c in ipairs(vim.lsp.get_clients({bufnr=0})) do table.insert(n,c.name) end print('<file> clients: '..table.concat(n,','))" \
  -c "qa" 2>&1
```
Expected: each line's client list includes the expected client name. (`omnisharp` may take noticeably longer to attach; if 3s isn't enough, retry with `sleep 8`.)

- [ ] **Step 4: Confirm tree-sitter highlighting is active for each file**

Run, for each file:
```bash
nvim --headless -u nvim/init.lua /tmp/nvim-config-check/<file> \
  -c "lua print('<file> highlighter: ' .. tostring(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil))" \
  -c "qa" 2>&1
```
Expected: every file prints `highlighter: true`.

- [ ] **Step 5: Confirm format-on-save runs without error**

```bash
nvim --headless -u nvim/init.lua /tmp/nvim-config-check/sample.py -c "write" -c "qa" 2>&1
```
Expected: no error output (confirms conform.nvim's `format_on_save` autocmd path executes cleanly; ruff must be installed via mason from Task 6 for this to have an effect, but the check here is just "no crash").

- [ ] **Step 6: Check startup time**

Run: `nvim --headless -u nvim/init.lua --startuptime /tmp/nvim-config-check/startuptime.log -c "qa" && tail -1 /tmp/nvim-config-check/startuptime.log`
Expected: total startup time well under 100ms (excluding the one-time plugin install cost already paid in Step 1). This is the direct check against the "don't be sluggish" goal from the spec. If it's high, look at which plugin's `event`/`cmd`/`ft` lazy-loading trigger is missing or too eager, and fix it before considering this task done.

- [ ] **Step 7: Interactive spot-check (manual, not headless)**

Launch `nvim -u nvim/init.lua /tmp/nvim-config-check/sample.rs` interactively and confirm by hand: completion popup appears while typing, `<leader>e` opens neo-tree, `<leader>ff` opens fzf-lua file picker, `K` shows hover info, colorscheme looks like Catppuccin Mocha, lualine renders at the bottom.

- [ ] **Step 8: Clean up scratch files**

Run: `rm -rf /tmp/nvim-config-check`

No commit for this task, it produces no repo changes. If every check above passes, the plan is complete.
