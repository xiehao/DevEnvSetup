#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCE_DIR="$(cd "${SCRIPT_DIR}/../../Resources" && pwd)"

if ! podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
  # Only match applehv images; exclude WSL-specific images which are Windows-only
  rootfs="$(ls "${RESOURCE_DIR}"/podman-machine-*.applehv.* 2>/dev/null | head -n 1 || true)"
  if [[ -n "${rootfs}" ]]; then
    podman machine init --image-path "${rootfs}" --rootful
  else
    podman machine init --rootful
  fi
fi

mirror_config=$(cat <<'EOF'
unqualified-search-registries = ["docker.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"

[[registry.mirror]]
location = "docker.m.daocloud.io"

[[registry.mirror]]
location = "mirror.ccs.tencentyun.com"
EOF
)

started_by_script="false"
status="$(podman machine inspect --format "{{.State}}" 2>/dev/null || true)"
if [[ "${status}" != "running" ]]; then
  podman machine start
  started_by_script="true"
fi

podman machine ssh -- "sudo mkdir -p /etc/containers/registries.conf.d"
printf "%s\n" "${mirror_config}" | podman machine ssh -- "sudo tee /etc/containers/registries.conf.d/99-cn-mirrors.conf > /dev/null"

if [[ "${started_by_script}" == "true" ]]; then
  podman machine stop
fi
