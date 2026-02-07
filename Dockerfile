# =============================================================================
# Portable Vim Development Environment
# =============================================================================
FROM ubuntu:22.04 AS base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# =============================================================================
# Install system packages
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    git \
    curl \
    wget \
    ca-certificates \
    gnupg \
    xclip \
    # Python 3
    python3 \
    python3-pip \
    python3-venv \
    # Build essentials (needed for some vim plugins)
    build-essential \
    # ripgrep
    ripgrep \
    # fzf
    fzf \
    # Additional tools
    locales \
    sudo \
    openssh-client \
    unzip \
    # Tauri / Rust native dependencies
    pkg-config \
    libssl-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.0-dev \
    libwebkit2gtk-4.1-dev \
    libjavascriptcoregtk-4.1-dev \
    libsoup-3.0-dev \
    libappindicator3-dev \
    librsvg2-dev \
    libsoup2.4-dev \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Install Neovim (latest from GitHub releases)
# =============================================================================
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.10.3/nvim-linux64.tar.gz \
    && tar xzf nvim-linux64.tar.gz \
    && mv nvim-linux64 /opt/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/vim \
    && rm nvim-linux64.tar.gz

# Install pynvim for Python plugin support (vim-ai needs this)
RUN pip3 install pynvim

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# =============================================================================
# Install Node.js 20.x (required for CoC and Claude Code)
# =============================================================================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Install lazygit
# =============================================================================
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin \
    && rm lazygit.tar.gz lazygit

# =============================================================================
# Install Claude Code CLI
# =============================================================================
RUN npm install -g @anthropic-ai/claude-code

# =============================================================================
# Install Rust toolchain + rust-analyzer
# =============================================================================
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
# Use a container-local target dir so host and container builds don't conflict
ENV CARGO_TARGET_DIR=/home/developer/.cargo-target
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable \
    && rustup component add rust-analyzer rust-src \
    && chmod -R a+rw $RUSTUP_HOME $CARGO_HOME

# =============================================================================
# Create non-root developer user
# =============================================================================
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# =============================================================================
# Set up Vim configuration
# =============================================================================
USER $USERNAME
WORKDIR /home/$USERNAME

# Create vim/nvim directories and cargo target directory
RUN mkdir -p ~/.vim/autoload ~/.vim/plugged ~/.vim/UltiSnips ~/.vim/session \
    && mkdir -p ~/.config/nvim ~/.config/coc/extensions ~/.local/share/nvim/site/autoload \
    && mkdir -p ~/.cargo-target

# Copy vim-plug manager (for both vim and nvim)
COPY --chown=$USERNAME:$USERNAME config/plug.vim /home/$USERNAME/.vim/autoload/plug.vim
COPY --chown=$USERNAME:$USERNAME config/plug.vim /home/$USERNAME/.local/share/nvim/site/autoload/plug.vim

# Copy vim configuration files
COPY --chown=$USERNAME:$USERNAME config/.vimrc /home/$USERNAME/.vimrc
COPY --chown=$USERNAME:$USERNAME config/coc-settings.json /home/$USERNAME/.vim/coc-settings.json
COPY --chown=$USERNAME:$USERNAME config/UltiSnips/ /home/$USERNAME/.vim/UltiSnips/

# Create nvim init that sources vimrc (for compatibility)
RUN echo 'set runtimepath^=~/.vim runtimepath+=~/.vim/after' > ~/.config/nvim/init.vim \
    && echo 'let &packpath = &runtimepath' >> ~/.config/nvim/init.vim \
    && echo 'source ~/.vimrc' >> ~/.config/nvim/init.vim

# =============================================================================
# Install Vim plugins
# =============================================================================
# Install plugins using neovim (handles "Press ENTER" prompts)
RUN nvim --headless -c 'PlugInstall --sync' -c 'qa' 2>&1 || true

# Ensure coc.nvim is properly installed
RUN cd ~/.vim/plugged/coc.nvim && npm ci --ignore-scripts || true

# Pre-install CoC extensions
RUN mkdir -p ~/.config/coc/extensions \
    && cd ~/.config/coc/extensions \
    && echo '{"dependencies":{}}' > package.json \
    && npm install --global-style --ignore-scripts --no-bin-links --no-package-lock --omit=dev \
        coc-json \
        coc-html \
        coc-css \
        coc-tsserver \
        coc-pyright \
        coc-eslint \
        coc-pairs \
        coc-rust-analyzer \
    || true

# =============================================================================
# Copy scripts and set up entrypoint
# =============================================================================
USER root
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/first-run.sh /usr/local/bin/first-run.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/first-run.sh

USER $USERNAME

# Default working directory
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
