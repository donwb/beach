#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION_FILE="${VERSION_FILE:-$SCRIPT_DIR/VERSION}"
IMAGE_REPO="${IMAGE_REPO:-donwb/beachsrv}"
DOCKERFILE="${DOCKERFILE:-dockerfile}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"
DOCTL_CONTEXT="${DOCTL_CONTEXT:-beachsvc}"
DO_APP_NAME="${DO_APP_NAME:-}"
DEPLOY="true"
BUMP="patch"
PINNED_VERSION=""

usage() {
  cat <<USAGE
Usage:
  ./release.sh [--bump patch|minor|major|none] [--version X.Y.Z] [--no-deploy]

Environment variables:
  IMAGE_REPO       Docker image repo (default: donwb/beachsrv)
  VERSION_FILE     Version file path (default: ./VERSION)
  DOCKERFILE       Dockerfile path (default: ./dockerfile)
  DOCKER_PLATFORM  Docker platform (default: linux/amd64)
  DOCTL_CONTEXT    doctl context name (default: beachsvc)
  DO_APP_ID        DigitalOcean App Platform app ID (optional)
  DO_APP_NAME      App Platform app name used to auto-resolve ID (optional)
  APP_DEPLOY_CMD   Explicit deploy command to run after push (optional)

Examples:
  ./release.sh
  ./release.sh --bump minor
  ./release.sh --version 1.4.2
  DO_APP_ID=1234 ./release.sh
  DO_APP_NAME=beachsvc ./release.sh
  DOCTL_CONTEXT=beachsvc DO_APP_ID=1234 ./release.sh
  APP_DEPLOY_CMD='doctl apps create-deployment 1234' ./release.sh
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

resolve_do_app_id() {
  local resolved=""

  if [[ -n "${DO_APP_ID:-}" ]]; then
    echo "$DO_APP_ID"
    return 0
  fi

  command_exists doctl || return 0

  if [[ -n "$DO_APP_NAME" ]]; then
    resolved="$(doctl --context "$DOCTL_CONTEXT" apps list --format ID,Spec.Name --no-header 2>/dev/null | awk -v name="$DO_APP_NAME" '$2 == name {print $1; exit}')"
    if [[ -n "$resolved" ]]; then
      echo "$resolved"
      return 0
    fi
  fi

  # If exactly one app exists in this context, use it.
  mapfile -t _app_ids < <(doctl --context "$DOCTL_CONTEXT" apps list --format ID --no-header 2>/dev/null || true)
  if [[ "${#_app_ids[@]}" -eq 1 ]]; then
    echo "${_app_ids[0]}"
    return 0
  fi

  return 0
}

is_semver() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

bump_semver() {
  local current="$1"
  local bump_kind="$2"

  IFS='.' read -r major minor patch <<<"$current"

  case "$bump_kind" in
    patch)
      patch=$((patch + 1))
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    none)
      ;;
    *)
      die "invalid bump type '$bump_kind'"
      ;;
  esac

  echo "${major}.${minor}.${patch}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bump)
      [[ $# -ge 2 ]] || die "--bump requires a value"
      BUMP="$2"
      shift 2
      ;;
    --version)
      [[ $# -ge 2 ]] || die "--version requires a value"
      PINNED_VERSION="$2"
      shift 2
      ;;
    --no-deploy)
      DEPLOY="false"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

command_exists docker || die "docker is required"

NEW_VERSION_FILE="false"
if [[ ! -f "$VERSION_FILE" ]]; then
  NEW_VERSION_FILE="true"
  echo "1.0.0" > "$VERSION_FILE"
  echo "Initialized $VERSION_FILE at 1.0.0"
fi

CURRENT_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
is_semver "$CURRENT_VERSION" || die "version in $VERSION_FILE must be X.Y.Z, found '$CURRENT_VERSION'"

if [[ -n "$PINNED_VERSION" ]]; then
  is_semver "$PINNED_VERSION" || die "--version must be X.Y.Z"
  NEXT_VERSION="$PINNED_VERSION"
elif [[ "$NEW_VERSION_FILE" == "true" && "$BUMP" == "patch" ]]; then
  NEXT_VERSION="1.0.0"
else
  NEXT_VERSION="$(bump_semver "$CURRENT_VERSION" "$BUMP")"
fi

echo "Current version: $CURRENT_VERSION"
echo "Next version:    $NEXT_VERSION"

echo "$NEXT_VERSION" > "$VERSION_FILE"

IMAGE_TAG="$IMAGE_REPO:$NEXT_VERSION"
LATEST_TAG="$IMAGE_REPO:latest"

echo "Building $IMAGE_TAG"
docker build --platform "$DOCKER_PLATFORM" -f "$DOCKERFILE" -t "$IMAGE_TAG" -t "$LATEST_TAG" .

echo "Pushing $IMAGE_TAG"
docker push "$IMAGE_TAG"

echo "Pushing $LATEST_TAG"
docker push "$LATEST_TAG"

if [[ "$DEPLOY" == "true" ]]; then
  if [[ -n "${APP_DEPLOY_CMD:-}" ]]; then
    echo "Running deploy command: $APP_DEPLOY_CMD"
    bash -lc "$APP_DEPLOY_CMD"
  else
    command_exists doctl || die "doctl is required for DigitalOcean deployment (or set APP_DEPLOY_CMD)"
    RESOLVED_DO_APP_ID="$(resolve_do_app_id)"
    if [[ -n "$RESOLVED_DO_APP_ID" ]]; then
      echo "Triggering App Platform deployment for app: $RESOLVED_DO_APP_ID (context: $DOCTL_CONTEXT)"
      doctl --context "$DOCTL_CONTEXT" apps create-deployment "$RESOLVED_DO_APP_ID"
    else
      die "No app selected. Set DO_APP_ID, or set DO_APP_NAME, or keep only one app in context '$DOCTL_CONTEXT'."
    fi
  fi
else
  echo "Skipping deploy (--no-deploy)."
fi

echo "Release complete: $IMAGE_TAG"
