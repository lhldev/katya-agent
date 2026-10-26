#!/usr/bin/env bash
# update.sh — rebuild chain for the hermes-agent (telegram) image.
#
#   What this script do:
#   1. Ensure the base repo (hermes-agent-desktop-docker) exists as a SIBLING
#      directory: clone it if missing, otherwise `git pull` to update it.
#   2. Build the base image locally (hermes-desktop:latest).
#   3. Rebuild this repo's image on top (hermes-desktop-telegram:latest).
#
# Usage:
#   ./update.sh        # clone-or-pull + build both images
#   ./update.sh up     # same, and also (re)create the running container
set -euo pipefail

THIS_REPO="$(cd "$(dirname "$0")" && pwd)"
PARENT="$(dirname "$THIS_REPO")"
DESKTOP_REPO="$PARENT/hermes-agent-desktop-docker"
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
  echo "    Not found — cloning into sibling directory"
  git clone "$DESKTOP_REPO_URL" "$DESKTOP_REPO"
fi

echo "==> 2/3  Build base image (hermes-desktop:latest)"
docker_cmd compose -f "$DESKTOP_REPO/docker-compose.yml" build

echo "==> 3/3  Rebuild image (hermes-desktop-telegram:latest)"
docker_cmd compose -f "$THIS_REPO/compose.yaml" build
