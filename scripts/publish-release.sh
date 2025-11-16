#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "--" ]; then
  shift
fi

REPO_INPUT="${GH_REPOSITORY:-${GITHUB_REPOSITORY:-}}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      if [[ $# -lt 2 ]]; then
        echo "--repo requires an argument in the form owner/repo" >&2
        exit 1
      fi
      REPO_INPUT="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [ $# -lt 1 ]; then
  echo "Usage: $0 [--repo owner/repo] <tag> [title] [notes-file]" >&2
  exit 1
fi

TAG="$1"
TITLE="${2:-$TAG}"
NOTES_FILE="${3:-}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZIP_NAME="${ZIP_NAME:-freqUI.zip}"
ZIP_PATH="${ROOT_DIR}/${ZIP_NAME}"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install it from https://cli.github.com/ and authenticate via 'gh auth login'." >&2
  exit 1
fi

"${ROOT_DIR}/scripts/build-release.sh" "$ZIP_NAME"

if [ ! -f "$ZIP_PATH" ]; then
  echo "Expected release archive ${ZIP_PATH} was not created." >&2
  exit 1
fi

echo "Publishing GitHub release ${TAG}..."
NOTES_ARGS=()
if [ -n "$NOTES_FILE" ]; then
  if [ -f "$NOTES_FILE" ]; then
    NOTES_ARGS=(--notes-file "$NOTES_FILE")
  else
    echo "Notes file '${NOTES_FILE}' not found. Falling back to default release notes." >&2
    NOTES_ARGS=(--notes "Automated freqUI release for ${TAG}")
  fi
else
  NOTES_ARGS=(--notes "Automated freqUI release for ${TAG}")
fi

GH_CMD=(gh release create "$TAG" "$ZIP_PATH" --title "$TITLE" "${NOTES_ARGS[@]}")
if [ -n "$REPO_INPUT" ]; then
  GH_CMD+=(--repo "$REPO_INPUT")
fi

"${GH_CMD[@]}"

echo "Release ${TAG} published with asset ${ZIP_NAME}."
