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
# Git Credential Storage (for HTTPS authentication)
# =============================================================================
GIT_CREDS_DIR="/home/developer/.git-credentials-store"
GIT_CREDS_FILE="$GIT_CREDS_DIR/.git-credentials"

if [ -d "$GIT_CREDS_DIR" ]; then
    # Configure git to use credential store with persistent file
    git config --global credential.helper "store --file=$GIT_CREDS_FILE"

    # Ensure proper permissions
    chmod 700 "$GIT_CREDS_DIR" 2>/dev/null || true
    if [ -f "$GIT_CREDS_FILE" ]; then
        chmod 600 "$GIT_CREDS_FILE"
    fi
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
