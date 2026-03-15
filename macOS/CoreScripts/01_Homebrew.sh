#!/usr/bin/env bash
set -euo pipefail

BREW_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
CORE_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
INSTALL_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git"
API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"

persist_env() {
  local profile="$HOME/.zprofile"
  if [[ ! -f "$profile" ]]; then
    touch "$profile"
  fi
  if ! grep -q "HOMEBREW_BOTTLE_DOMAIN" "$profile"; then
    {
      echo ""
      echo "# Homebrew mirrors for CN"
      echo "export HOMEBREW_BREW_GIT_REMOTE=\"${BREW_MIRROR}\""
      echo "export HOMEBREW_CORE_GIT_REMOTE=\"${CORE_MIRROR}\""
      echo "export HOMEBREW_INSTALL_FROM_API=1"
      echo "export HOMEBREW_API_DOMAIN=\"${API_DOMAIN}\""
      echo "export HOMEBREW_BOTTLE_DOMAIN=\"${BOTTLE_DOMAIN}\""
    } >> "$profile"
  fi

  if [[ -x "/opt/homebrew/bin/brew" ]] && ! grep -q "brew shellenv" "$profile"; then
    echo "eval \"$(/opt/homebrew/bin/brew shellenv)\"" >> "$profile"
  fi
}

export HOMEBREW_BREW_GIT_REMOTE="${BREW_MIRROR}"
export HOMEBREW_CORE_GIT_REMOTE="${CORE_MIRROR}"
export HOMEBREW_INSTALL_FROM_API=1
export HOMEBREW_API_DOMAIN="${API_DOMAIN}"
export HOMEBREW_BOTTLE_DOMAIN="${BOTTLE_DOMAIN}"

if ! command -v brew >/dev/null 2>&1; then
  tmpdir="$(mktemp -d)"
  git clone --depth=1 "${INSTALL_MIRROR}" "${tmpdir}/brew-install"
  /bin/bash "${tmpdir}/brew-install/install.sh"
  rm -rf "${tmpdir}"
fi

persist_env

if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

BREW_REPO="$(brew --repo)"
CORE_REPO="$(brew --repo homebrew/core)"
git -C "$BREW_REPO" remote set-url origin "$BREW_MIRROR"
git -C "$CORE_REPO" remote set-url origin "$CORE_MIRROR"

brew update
brew install podman
brew install --cask visual-studio-code
