#!/usr/bin/env bash
# setup.sh — clone all app repos into repos/
# Run this once after cloning todo-meta, then re-run to pull latest changes.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="$SCRIPT_DIR/repos"

# Update these URLs to match where you've pushed the repos
FRONTEND_URL="${FRONTEND_URL:-git@github.com:briansokol/todo-frontend.git}"
BACKEND_URL="${BACKEND_URL:-git@github.com:briansokol/todo-backend.git}"
CONTRACTS_URL="${CONTRACTS_URL:-git@github.com:briansokol/todo-contracts.git}"
INFRA_URL="${INFRA_URL:-git@github.com:briansokol/todo-infra.git}"

clone_or_pull() {
  local name="$1"
  local url="$2"
  local dest="$REPOS_DIR/$name"

  if [ -d "$dest/.git" ]; then
    echo "  Updating $name..."
    git -C "$dest" pull --ff-only
  else
    echo "  Cloning $name..."
    git clone "$url" "$dest"
  fi
}

mkdir -p "$REPOS_DIR"
echo "Setting up Todo App repos in $REPOS_DIR..."

clone_or_pull "todo-frontend"  "$FRONTEND_URL"
clone_or_pull "todo-backend"   "$BACKEND_URL"
clone_or_pull "todo-contracts" "$CONTRACTS_URL"
clone_or_pull "todo-infra"     "$INFRA_URL"

echo ""
echo "Done. Repos available at:"
ls "$REPOS_DIR"
