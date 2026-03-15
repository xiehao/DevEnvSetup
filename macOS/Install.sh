#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_step() {
  local step="$1"
  echo ">>> Running ${step}"
  bash "${SCRIPT_DIR}/CoreScripts/${step}.sh"
}

run_step "01_Homebrew"
run_step "02_Podman"
run_step "03_Image"

echo "Setup completed."
