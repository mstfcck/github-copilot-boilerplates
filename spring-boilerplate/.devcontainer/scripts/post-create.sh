#!/usr/bin/env bash
set -euo pipefail

# Display Java and Maven versions
java -version || true
mvn -v || true

# Ensure Git safe directory
if [ -n "${WORKSPACE_FOLDER:-}" ]; then
  git config --global --add safe.directory "${WORKSPACE_FOLDER}"
fi

echo "[post-create] Environment ready."
