#!/usr/bin/env bash
set -euo pipefail

confirm() {
  local prompt="$1"
  read -r -p "${prompt} (y/N): " ans
  case "${ans}" in
    y|Y) return 0 ;;
    *) return 1 ;;
  esac
}

echo "=========================================="
echo "  Environment Uninstaller (macOS)"
echo "=========================================="
echo " [1] Remove Podman Machine (All images/containers)"
echo " [2] Uninstall VS Code and Podman (Homebrew)"
echo " [3] Uninstall Homebrew"
echo " [4] Clean containers config/data directories"
echo " [A] Uninstall ALL"
echo " [Q] Quit"
echo "------------------------------------------"

read -r -p "Select options (e.g., 1,2,4): " input
if [[ -z "${input}" || "${input}" == "q" || "${input}" == "Q" ]]; then
  echo "Cancelled."
  exit 0
fi

actions=()
if [[ "${input}" == "a" || "${input}" == "A" ]]; then
  actions=(1 2 3 4)
else
  IFS=',' read -r -a actions <<< "${input}"
fi

run_action() {
  local id="$1"
  case "${id}" in
    1)
      echo ">>> Removing Podman Machine..."
      if command -v podman >/dev/null 2>&1; then
        podman machine stop >/dev/null 2>&1 || true
        podman machine rm -f || true
      fi
      ;;
    2)
      echo ">>> Uninstalling VS Code and Podman..."
      if command -v brew >/dev/null 2>&1; then
        brew uninstall podman >/dev/null 2>&1 || true
        brew uninstall --cask visual-studio-code >/dev/null 2>&1 || true
      fi
      ;;
    3)
      echo ">>> Uninstalling Homebrew..."
      if command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
      fi
      ;;
    4)
      echo ">>> Cleaning containers config/data..."
      rm -rf "${HOME}/.config/containers" || true
      rm -rf "${HOME}/.local/share/containers" || true
      ;;
    *)
      ;;
  esac
}

if confirm "Proceed with selected operations"; then
  for id in "${actions[@]}"; do
    run_action "$(echo "${id}" | xargs)"
  done
  echo "Cleanup completed."
else
  echo "Cancelled."
fi
