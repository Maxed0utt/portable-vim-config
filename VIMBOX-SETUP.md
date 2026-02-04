# Vimbox Shell Function Setup

This document describes the `vimbox` bash function that launches the Vim development container.

## Problem

The original setup had several issues:

1. **CoC extensions re-downloaded every time** - The `~/.config/coc` directory inside the container wasn't persisted, so CoC would reinstall all extensions from `g:coc_global_extensions` on every container start.

2. **Container exited when vim closed** - Running `vim .` as the container command meant exiting vim killed the container, preventing use of other tools like `lazygit` or `claude`.

3. **Only one instance allowed** - Hardcoded container name `vim-dev` prevented running multiple instances for different projects.

## Solution

### 1. Persist CoC Extensions

Added a volume mount for CoC data:

```bash
local COC_DATA="${HOME}/.config/vim-coc-data"
mkdir -p "$COC_DATA"
# ...
-v "$COC_DATA:/home/developer/.config/coc"
```

Extensions are now stored on the host at `~/.config/vim-coc-data` and persist across container restarts. The first run will still download extensions, but subsequent runs use the cached versions.

### 2. Keep Container Running After Vim Exits

Changed the container command from `vim .` to:

```bash
bash -ic "vim .; exec bash"
```

This:
- Opens vim automatically when container starts
- Drops you into a bash shell when you quit vim
- Container only exits when you `exit` the shell

### 3. Unique Container Names

Generate unique names based on workspace directory and process ID:

```bash
local WORKSPACE_NAME=$(basename "$WORKSPACE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
local CONTAINER_NAME="vim-${WORKSPACE_NAME}-$$"
```

This allows running multiple vimbox instances for different projects simultaneously.

## Complete vimbox Function

Add this to your `~/.bashrc`:

```bash
# Portable Vim Development Environment
export GIT_USER_NAME="your-name"
export GIT_USER_EMAIL="your-email@example.com"

vimbox() {
    local IMAGE_NAME="vim-dev-environment:latest"
    local WORKSPACE="${1:-$(pwd)}"
    local WORKSPACE_NAME=$(basename "$WORKSPACE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
    local CONTAINER_NAME="vim-${WORKSPACE_NAME}-$$"
    local CLAUDE_CONFIG="${HOME}/.config/claude-docker"
    local COC_DATA="${HOME}/.config/vim-coc-data"

    mkdir -p "$CLAUDE_CONFIG" "$COC_DATA"

    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        --hostname "$WORKSPACE_NAME" \
        -e "GIT_USER_NAME=${GIT_USER_NAME:-}" \
        -e "GIT_USER_EMAIL=${GIT_USER_EMAIL:-}" \
        -e "TERM=xterm-256color" \
        -e "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}" \
        -v "$WORKSPACE:/workspace" \
        -v "${HOME}/.ssh:/home/developer/.ssh-host:ro" \
        -v "$CLAUDE_CONFIG:/home/developer/.claude" \
        -v "$COC_DATA:/home/developer/.config/coc" \
        -w /workspace \
        "$IMAGE_NAME" \
        bash -ic "vim .; exec bash"
}
```

## Usage

```bash
# Open vimbox in current directory
vimbox

# Open vimbox in specific directory
vimbox /path/to/project
```

## Persisted Data Locations

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/workspace` | Current directory (or specified path) | Project files |
| `/home/developer/.claude` | `~/.config/claude-docker` | Claude Code authentication |
| `/home/developer/.config/coc` | `~/.config/vim-coc-data` | CoC extensions cache |
| `/home/developer/.ssh-host` | `~/.ssh` (read-only) | SSH keys for git |
