#!/bin/bash
# =============================================================================
# Vim Development Container - Quick Run Script
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="${CONTAINER_NAME:-vim-dev}"
IMAGE_NAME="${IMAGE_NAME:-vim-dev-environment:latest}"
WORKSPACE="${WORKSPACE:-$(pwd)}"

# Git configuration (set these in your shell profile)
GIT_USER_NAME="${GIT_USER_NAME:-}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-}"

# Paths
SSH_PATH="${SSH_PATH:-$HOME/.ssh}"
CLAUDE_CONFIG="${CLAUDE_CONFIG:-$HOME/.config/claude-docker}"

# Ensure Claude config directory exists
mkdir -p "$CLAUDE_CONFIG"

# Build if image doesn't exist
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo "Building image..."
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
fi

# Run the container
echo "Starting vim-dev environment..."
echo "Workspace: $WORKSPACE"
echo ""

docker run -it --rm \
    --name "$CONTAINER_NAME" \
    --hostname vim-dev \
    -e "GIT_USER_NAME=$GIT_USER_NAME" \
    -e "GIT_USER_EMAIL=$GIT_USER_EMAIL" \
    -e "TERM=xterm-256color" \
    -e "ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-}" \
    -v "$WORKSPACE:/workspace" \
    -v "$SSH_PATH:/home/developer/.ssh-host:ro" \
    -v "$CLAUDE_CONFIG:/home/developer/.claude" \
    -w /workspace \
    "$IMAGE_NAME" \
    "${@:-bash}"
