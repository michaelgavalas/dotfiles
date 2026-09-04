#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<'EOF'
Usage: bootstrap.sh [FLAGS]

With no flags, sets up everything. Otherwise, only the given components
are set up.

  --ghostty   Ghostty config
  --tmux      tmux config, and clones tpm if missing
  --zsh       zsh config, and sets zsh as your login shell
  --starship  starship prompt config
  --yazi      yazi config
  --nvim      Neovim config
  -h, --help  show this help
EOF
}

link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "already linked: $dest"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mv "$dest" "$dest.bak"
        echo "backed up existing $dest -> $dest.bak"
    fi

    ln -sf "$src" "$dest"
    echo "linked $dest -> $src"
}

setup_ghostty() {
    link "ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
}

setup_tmux() {
    link "tmux/.tmux.conf" "$HOME/.tmux.conf"

    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "already cloned: tpm"
    else
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
}

setup_zsh() {
    link "zsh/.zshrc" "$HOME/.zshrc"

    if [ "$(basename "$SHELL")" = "zsh" ]; then
        echo "login shell is already zsh"
    else
        chsh -s "$(which zsh)"
        echo "login shell set to zsh"
    fi
}

setup_starship() {
    link "starship/starship.toml" "$HOME/.config/starship.toml"
}

setup_yazi() {
    link "yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
    link "yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
    link "yazi/package.toml" "$HOME/.config/yazi/package.toml"
}

setup_nvim() {
    link "nvim" "$HOME/.config/nvim"
}

selected=()

for arg in "$@"; do
    case "$arg" in
        --ghostty|--tmux|--zsh|--starship|--yazi|--nvim)
            selected+=("${arg#--}")
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "unknown flag: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ ${#selected[@]} -eq 0 ]; then
    selected=(ghostty tmux zsh starship yazi nvim)
fi

for component in "${selected[@]}"; do
    "setup_$component"
done

echo "done"
