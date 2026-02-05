#!/bin/bash
set -e

# =============================================================================
# Git Configuration
# =============================================================================
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Mark workspace as safe directory
if [ -d "/workspace" ]; then
    git config --global --add safe.directory /workspace
fi

# =============================================================================
# GitHub Token Authentication (for HTTPS)
# =============================================================================
if [ -n "$GITHUB_TOKEN" ]; then
    # Write credentials directly to git-credentials file
    GIT_CREDS_FILE="/home/developer/.git-credentials"
    GITHUB_USER="${GIT_USER_NAME:-git}"
    echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > "$GIT_CREDS_FILE"
    chmod 600 "$GIT_CREDS_FILE"
    git config --global credential.helper "store --file=$GIT_CREDS_FILE"

    # URL rewriting to automatically include credentials (for lazygit compatibility)
    git config --global url."https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
fi

# =============================================================================
# SSH Key Setup
# =============================================================================
if [ -d "/home/developer/.ssh-host" ] && [ "$(ls -A /home/developer/.ssh-host 2>/dev/null)" ]; then
    mkdir -p ~/.ssh
    cp -r /home/developer/.ssh-host/* ~/.ssh/ 2>/dev/null || true
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_* 2>/dev/null || true
    chmod 644 ~/.ssh/*.pub 2>/dev/null || true
    chmod 644 ~/.ssh/known_hosts 2>/dev/null || true
    chmod 644 ~/.ssh/config 2>/dev/null || true
fi

# =============================================================================
# Claude Code Check
# =============================================================================
if [ ! -f "/home/developer/.claude/.credentials.json" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "=================================================="
    echo "Claude Code is not authenticated."
    echo "Run 'claude' to authenticate via browser."
    echo "=================================================="
fi

# =============================================================================
# First Run
# =============================================================================
FIRST_RUN_MARKER="/home/developer/.container-initialized"
if [ ! -f "$FIRST_RUN_MARKER" ]; then
    /usr/local/bin/first-run.sh
    touch "$FIRST_RUN_MARKER"
fi

# =============================================================================
# Execute Command
# =============================================================================
exec "$@"
