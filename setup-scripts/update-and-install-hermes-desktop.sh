#!/usr/bin/env bash
# update-and-install-hermes-desktop.sh — rebuild chain for the hermes-agent image.
#
#   1. Ensure the base repo (hermes-agent-desktop-docker) exists nested in the
#      agent repo (gitignored): clone it if missing, otherwise `git pull`.
#   2. Build the base image locally (hermes-desktop:latest).
#   3. Rebuild the agent image on top (hermes-desktop-telegram:latest).
#
# Usage:
#   ./update-and-install-hermes-desktop.sh        # clone-or-pull + build
#   ./update-and-install-hermes-desktop.sh up     # same, plus restart container
set -euo pipefail

# This script lives in <repo>/setup-scripts/, so the repo root is its parent.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DESKTOP_REPO="$REPO_ROOT/hermes-agent-desktop-docker"
DESKTOP_REPO_URL="https://github.com/Neoplanetz/hermes-agent-desktop-docker.git"

# Fall back to sudo only if the current user can't talk to docker directly.
docker_cmd() {
  docker "$@" 2>/dev/null || sudo docker "$@"
}

echo "==> 1/3  Sync base repo: $DESKTOP_REPO"
if [ -d "$DESKTOP_REPO/.git" ]; then
  echo "    Exists — pulling latest changes"
  git -C "$DESKTOP_REPO" pull --ff-only
else
  echo "    Not found — cloning"
  git clone "$DESKTOP_REPO_URL" "$DESKTOP_REPO"
fi

echo "==> 2/3  Build base image (hermes-desktop:latest)"
docker_cmd compose -f "$DESKTOP_REPO/docker-compose.yml" build

echo "==> 3/3  Rebuild image (hermes-desktop-telegram:latest)"
docker_cmd compose -f "$REPO_ROOT/compose.yaml" build

if [[ "${1:-}" == "up" ]]; then
  echo "==> Recreating container with the new image"
  docker_cmd compose -f "$REPO_ROOT/compose.yaml" up -d
  echo "==> Done. Container is up."
else
  echo "==> Done. Run '$(basename "$0") up' to also restart the container."
fi
