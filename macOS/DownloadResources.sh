#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCE_DIR="$(cd "${SCRIPT_DIR}/../Resources" && pwd)"
mkdir -p "${RESOURCE_DIR}"

# Detect architecture
ARCH="$(uname -m)"  # arm64 or x86_64
if [[ "${ARCH}" == "arm64" ]]; then
  PODMAN_ARCH="aarch64"
else
  PODMAN_ARCH="x86_64"
fi

# Podman applehv OS (v5.7.1) — macOS uses Apple Hypervisor, NOT WSL
PODMAN_OS_URL="https://github.com/containers/podman-machine-os/releases/download/v5.7.1/podman-machine.${PODMAN_ARCH}.applehv.raw.gz"
PODMAN_OS_FILE="podman-machine-${PODMAN_ARCH}.applehv.raw.gz"

TARGET="${RESOURCE_DIR}/${PODMAN_OS_FILE}"
if [[ ! -f "${TARGET}" ]]; then
  echo "Downloading ${PODMAN_OS_FILE}..."
  curl -L -o "${TARGET}" "${PODMAN_OS_URL}"
else
  echo "${PODMAN_OS_FILE} already exists, skipping."
fi

echo "Download complete for ${ARCH} architecture."
echo "Please also place Dockerfile, arch-cpp-dev.tar.zst and Container.code-profile in the root Resources folder."

