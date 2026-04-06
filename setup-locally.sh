#!/usr/bin/env bash
# =============================================================================
# Local Setup Script — mirrors the Docker dev environment onto your machine
# Tested on Pop!_OS / Ubuntu 24.04 (x86_64)
#
# Usage: sudo bash setup-locally.sh
#   (must be run with sudo so apt/system installs work,
#    but user-space config is applied to the real user via $SUDO_USER)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_CFG="$SCRIPT_DIR/docker-dev-env/config"
VIMRC_REPO="$SCRIPT_DIR/max-vimrc"
WEZTERM_REPO="$SCRIPT_DIR/wezterm-config"

# Detect the real (non-root) user when run via sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

if [ "$REAL_HOME" = "" ]; then
    echo "ERROR: Could not determine home directory for user $REAL_USER"
    exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
step()  { echo -e "\n${GREEN}==== $* ====${NC}"; }

# Run a command as the real user (not root)
as_user() { sudo -u "$REAL_USER" -- "$@"; }

info "Running as root, user-space config targets: $REAL_USER ($REAL_HOME)"

# =============================================================================
# 1. System packages
# =============================================================================
step "Installing system packages"
apt-get update
apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    gnupg \
    xclip \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    ripgrep \
    fzf \
    locales \
    openssh-client \
    unzip \
    pkg-config \
    libssl-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    libjavascriptcoregtk-4.1-dev \
    libsoup-3.0-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    inotify-tools

# Ensure locale
locale-gen en_US.UTF-8 || true

# =============================================================================
# 2. Neovim (v0.10.3)
# =============================================================================
step "Installing Neovim"
if command -v nvim &>/dev/null; then
    info "Neovim already installed: $(nvim --version | head -1)"
else
    NVIM_VERSION="v0.10.3"
    info "Downloading Neovim $NVIM_VERSION..."
    curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"
    rm -rf /opt/nvim
    tar xzf nvim-linux64.tar.gz -C /opt
    mv /opt/nvim-linux64 /opt/nvim
    ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    # Only alias vim -> nvim if vim isn't already installed
    if ! command -v vim &>/dev/null; then
        ln -sf /opt/nvim/bin/nvim /usr/local/bin/vim
    fi
    rm -f nvim-linux64.tar.gz
    info "Neovim installed: $(nvim --version | head -1)"
fi

# pynvim (needed for vim-ai and other Python plugins)
as_user pip3 install --user pynvim 2>/dev/null \
    || as_user pip3 install pynvim --break-system-packages 2>/dev/null \
    || true
info "pynvim installed"

# =============================================================================
# 3. Node.js 20.x
# =============================================================================
step "Installing Node.js 20.x"
if command -v node &>/dev/null; then
    info "Node.js already installed: $(node --version)"
else
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    info "Node.js installed: $(node --version)"
fi

# Ensure npm is available
if ! command -v npm &>/dev/null; then
    warn "npm not found after Node.js install — something went wrong"
    exit 1
fi

# yarn (needed by vim-instant-markdown plugin)
if ! command -v yarn &>/dev/null; then
    npm install -g yarn
    info "yarn installed"
fi

# =============================================================================
# 4. lazygit
# =============================================================================
step "Installing lazygit"
if command -v lazygit &>/dev/null; then
    info "lazygit already installed"
else
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    install /tmp/lazygit /usr/local/bin
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
    info "lazygit installed"
fi

# =============================================================================
# 5. Rust toolchain + rust-analyzer
# =============================================================================
step "Checking Rust toolchain"
if as_user bash -c 'command -v rustc' &>/dev/null; then
    info "Rust already installed: $(as_user rustc --version)"
else
    as_user bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable'
    info "Rust installed"
fi

# Ensure rust-analyzer component
if ! as_user rustup component list 2>/dev/null | grep -q "rust-analyzer.*installed"; then
    as_user rustup component add rust-analyzer rust-src
    info "rust-analyzer component added"
else
    info "rust-analyzer already installed"
fi

# =============================================================================
# 6. Erlang + Elixir
# =============================================================================
step "Checking Erlang/Elixir"
if command -v erl &>/dev/null; then
    info "Erlang already installed"
else
    apt-get install -y --no-install-recommends erlang
    info "Erlang installed"
fi

if command -v elixir &>/dev/null; then
    info "Elixir already installed: $(elixir --version | tail -1)"
else
    info "Installing Elixir from precompiled release..."
    OTP_MAJOR=$(erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().')
    curl -fsSL "https://github.com/elixir-lang/elixir/releases/download/v1.16.3/elixir-otp-${OTP_MAJOR}.zip" -o /tmp/elixir.zip
    mkdir -p /usr/local/elixir
    unzip -o /tmp/elixir.zip -d /usr/local/elixir
    rm /tmp/elixir.zip
    # Add to PATH if not already there
    if ! echo "$PATH" | grep -q "/usr/local/elixir/bin"; then
        echo 'export PATH="/usr/local/elixir/bin:$PATH"' >> "$REAL_HOME/.bashrc"
        export PATH="/usr/local/elixir/bin:$PATH"
    fi
    info "Elixir installed"
fi

# Hex + Rebar (Elixir package managers)
if command -v mix &>/dev/null; then
    as_user mix local.hex --force
    as_user mix local.rebar --force
    info "Hex and Rebar configured"
fi

# =============================================================================
# 7. Claude Code CLI
# =============================================================================
step "Checking Claude Code"
if command -v claude &>/dev/null; then
    info "Claude Code already installed: $(claude --version 2>/dev/null || echo 'installed')"
else
    npm install -g @anthropic-ai/claude-code
    info "Claude Code installed"
fi

# =============================================================================
# 8. Vim/Neovim configuration (all as real user)
# =============================================================================
step "Setting up Vim/Neovim configuration"

# Create directories
as_user mkdir -p "$REAL_HOME/.vim/autoload" "$REAL_HOME/.vim/plugged" "$REAL_HOME/.vim/UltiSnips" "$REAL_HOME/.vim/session"
as_user mkdir -p "$REAL_HOME/.config/nvim" "$REAL_HOME/.config/coc/extensions" "$REAL_HOME/.local/share/nvim/site/autoload"

# Install vim-plug
if [ ! -f "$REAL_HOME/.vim/autoload/plug.vim" ]; then
    as_user cp "$DOCKER_CFG/plug.vim" "$REAL_HOME/.vim/autoload/plug.vim"
    info "vim-plug installed (vim)"
else
    info "vim-plug already present (vim)"
fi

if [ ! -f "$REAL_HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    as_user cp "$DOCKER_CFG/plug.vim" "$REAL_HOME/.local/share/nvim/site/autoload/plug.vim"
    info "vim-plug installed (nvim)"
else
    info "vim-plug already present (nvim)"
fi

# Copy .vimrc (use the docker version which has Rust + Elixir support)
if [ -f "$REAL_HOME/.vimrc" ]; then
    warn "Backing up existing ~/.vimrc to ~/.vimrc.bak"
    as_user cp "$REAL_HOME/.vimrc" "$REAL_HOME/.vimrc.bak"
fi
as_user cp "$DOCKER_CFG/.vimrc" "$REAL_HOME/.vimrc"
info ".vimrc installed"

# coc-settings.json
as_user tee "$REAL_HOME/.vim/coc-settings.json" > /dev/null << 'COCSETTINGS'
{
    "typescript.suggest.autoImports": true,
    "typescript.preferences.includePackageJsonAutoImports": "on",
    "svelte.enable-ts-plugin": true,
    "elixirLS.dialyzerEnabled": true,
    "elixirLS.fetchDeps": false
}
COCSETTINGS
info "coc-settings.json installed"

# UltiSnips — copy all snippets from docker config
as_user cp "$DOCKER_CFG/UltiSnips/"*.snippets "$REAL_HOME/.vim/UltiSnips/" 2>/dev/null || true
info "UltiSnips snippets copied"

# nvim init.vim — sources the shared .vimrc
as_user tee "$REAL_HOME/.config/nvim/init.vim" > /dev/null << 'NVIMINIT'
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
NVIMINIT
info "nvim init.vim created"

# =============================================================================
# 9. Install Vim plugins (as real user)
# =============================================================================
step "Installing Vim plugins (headless)"
as_user nvim --headless -c 'PlugInstall --sync' -c 'qa' 2>&1 || true
info "Vim plugins installed"

# Ensure coc.nvim is built
if [ -d "$REAL_HOME/.vim/plugged/coc.nvim" ] && [ ! -f "$REAL_HOME/.vim/plugged/coc.nvim/build/index.js" ]; then
    info "Building coc.nvim..."
    as_user bash -c "cd '$REAL_HOME/.vim/plugged/coc.nvim' && npm ci --ignore-scripts" 2>/dev/null || true
fi

# =============================================================================
# 10. Install CoC extensions (as real user)
# =============================================================================
step "Installing CoC extensions"
as_user mkdir -p "$REAL_HOME/.config/coc/extensions"
as_user bash -c "
    cd '$REAL_HOME/.config/coc/extensions'
    [ ! -f package.json ] && echo '{\"dependencies\":{}}' > package.json
    npm install --global-style --ignore-scripts --no-bin-links --no-package-lock --omit=dev \
        coc-json \
        coc-html \
        coc-css \
        coc-tsserver \
        coc-pyright \
        coc-eslint \
        coc-pairs \
        coc-rust-analyzer \
        coc-elixir \
        || true
"
info "CoC extensions installed"

# =============================================================================
# 11. Wezterm config
# =============================================================================
step "Checking Wezterm configuration"
if [ -L "$REAL_HOME/.wezterm.lua" ]; then
    info "Wezterm config already symlinked: $(readlink "$REAL_HOME/.wezterm.lua")"
elif [ -f "$WEZTERM_REPO/.wezterm.lua" ]; then
    if [ -f "$REAL_HOME/.wezterm.lua" ]; then
        warn "Backing up existing ~/.wezterm.lua to ~/.wezterm.lua.bak"
        as_user cp "$REAL_HOME/.wezterm.lua" "$REAL_HOME/.wezterm.lua.bak"
    fi
    as_user ln -sf "$WEZTERM_REPO/.wezterm.lua" "$REAL_HOME/.wezterm.lua"
    info "Wezterm config symlinked"
fi

# =============================================================================
# Done!
# =============================================================================
step "Setup complete!"
echo ""
echo "Installed / verified:"
echo "  neovim    — $(nvim --version 2>/dev/null | head -1)"
echo "  node      — $(node --version 2>/dev/null)"
echo "  npm       — $(npm --version 2>/dev/null)"
echo "  rustc     — $(as_user rustc --version 2>/dev/null)"
echo "  rust-analyzer — $(as_user rust-analyzer --version 2>/dev/null || echo 'via rustup')"
echo "  erlang    — $(erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().' 2>/dev/null)"
echo "  elixir    — $(elixir --version 2>/dev/null | tail -1)"
echo "  lazygit   — $(lazygit --version 2>/dev/null | head -1 || echo 'installed')"
echo "  claude    — $(claude --version 2>/dev/null || echo 'installed')"
echo "  ripgrep   — $(rg --version 2>/dev/null | head -1)"
echo "  fzf       — $(fzf --version 2>/dev/null)"
echo ""
echo "Config files:"
echo "  ~/.vimrc              — Neovim/Vim config"
echo "  ~/.vim/coc-settings.json — CoC language server config"
echo "  ~/.vim/UltiSnips/     — Code snippets"
echo "  ~/.config/nvim/init.vim  — Neovim init (sources .vimrc)"
echo "  ~/.wezterm.lua        — Wezterm terminal config"
echo ""
echo "Quick start:"
echo "  nvim         — Start Neovim"
echo "  lazygit      — Git TUI"
echo "  claude       — Claude Code CLI"
echo "  rg <pattern> — ripgrep search"
echo "  fzf          — Fuzzy finder"
