#!/usr/bin/env bash
# Install repo-managed git hooks into .git/hooks/.
# Run once after cloning the repo.

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cp "$REPO_ROOT/scripts/pre-commit" "$REPO_ROOT/.git/hooks/pre-commit"
chmod +x "$REPO_ROOT/.git/hooks/pre-commit"
echo "✅ pre-commit hook installed."
