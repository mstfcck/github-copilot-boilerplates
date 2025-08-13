#!/usr/bin/env bash
set -euo pipefail

# Pre-cache Maven dependencies if pom.xml exists in the workspace folder
WORKDIR="${WORKSPACE_FOLDER:-/workspaces}"
if [ -f "$WORKDIR/pom.xml" ]; then
  echo "[on-create] Pre-caching Maven dependencies..."
  pushd "$WORKDIR" >/dev/null
  mvn -B -q -DskipTests dependency:go-offline || true
  popd >/dev/null
fi
