#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCE_DIR="$(cd "${SCRIPT_DIR}/../../Resources" && pwd)"

status="$(podman machine inspect --format "{{.State}}" 2>/dev/null || true)"
if [[ "${status}" != "running" ]]; then
  podman machine start
fi

if podman images -q arch-cpp-dev >/dev/null 2>&1; then
  echo "Image arch-cpp-dev already exists. Skipping."
  exit 0
fi

tar="${RESOURCE_DIR}/arch-cpp-dev.tar.zst"
df="${RESOURCE_DIR}/Dockerfile"

if [[ -f "${tar}" ]]; then
  podman load -i "${tar}"
elif [[ -f "${df}" ]]; then
  podman build -t arch-cpp-dev:latest -f "${df}" "${RESOURCE_DIR}"
else
  echo "[WARN] No image source found. Environment may be incomplete."
fi
