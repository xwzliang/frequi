#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZIP_NAME="${1:-freqUI.zip}"

cd "$ROOT_DIR"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required to run this script. Install it via npm (npm install -g pnpm) or corepack." >&2
  exit 1
fi

echo "Installing dependencies (pnpm install --frozen-lockfile)..."
pnpm install --frozen-lockfile

echo "Building production bundle (pnpm run build)..."
pnpm run build

if [ ! -d "dist" ]; then
  echo "dist/ directory not found after build. Aborting." >&2
  exit 1
fi

echo "Packaging dist/ contents into ${ZIP_NAME}..."
rm -f "${ZIP_NAME}"
(
  cd dist
  zip -r "../${ZIP_NAME}" . >/dev/null
)

echo "Done. Release archive available at ${ROOT_DIR}/${ZIP_NAME}"
