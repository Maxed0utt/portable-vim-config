#!/bin/bash

# Ensure CoC is properly initialized
if [ -d ~/.vim/plugged/coc.nvim ] && [ ! -f ~/.vim/plugged/coc.nvim/build/index.js ]; then
    echo "Initializing CoC..."
    cd ~/.vim/plugged/coc.nvim && npm ci --ignore-scripts 2>/dev/null || true
fi

echo "==================================="
echo "Vim Development Environment"
echo "==================================="
echo ""
echo "Quick start commands:"
echo "  vim           - Start vim editor"
echo "  lazygit       - Git TUI"
echo "  claude        - Claude Code CLI"
echo "  rg <pattern>  - ripgrep search"
echo "  fzf           - Fuzzy finder"
echo ""
echo "Your workspace is mounted at /workspace"
echo "==================================="
