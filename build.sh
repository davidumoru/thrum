#!/usr/bin/env bash
set -euo pipefail

# Ensure script runs from the repository root
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0")"

APP_NAME="thrum"
SCHEME="thrum"
PROJECT="thrum.xcodeproj"
CONFIGURATION="Debug"
DERIVED_DATA_PATH="build"
DO_RUN=false
DO_CLEAN=false

usage() {
  cat <<EOF
Usage: ./build.sh [options] [command]

Commands:
  build             Build the application (default)
  run               Build and launch the application
  clean             Remove build output directory

Options:
  -r, --release     Build Release configuration (default is Debug)
  -d, --debug       Build Debug configuration
  -c, --clean       Clean build directory before building
  -h, --help        Show this help message
EOF
}

# Parse options and commands
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--release|release)
      CONFIGURATION="Release"
      shift
      ;;
    -d|--debug|debug)
      CONFIGURATION="Debug"
      shift
      ;;
    -c|--clean)
      DO_CLEAN=true
      shift
      ;;
    clean)
      echo "==> Cleaning $DERIVED_DATA_PATH..."
      rm -rf "$DERIVED_DATA_PATH"
      exit 0
      ;;
    run|--run)
      DO_RUN=true
      shift
      ;;
    build)
      shift
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$DO_CLEAN" == true ]]; then
  echo "==> Cleaning $DERIVED_DATA_PATH..."
  rm -rf "$DERIVED_DATA_PATH"
fi

SIGN_SETTINGS=(CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO)
if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
  echo "==> Using DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM"
  SIGN_SETTINGS=(DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" -allowProvisioningUpdates)
fi

echo "==> Building $APP_NAME ($CONFIGURATION)..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  "${SIGN_SETTINGS[@]}" \
  build

APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/$APP_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "==> Build failed: $APP_PATH was not produced." >&2
  exit 1
fi

echo "==> Verifying signature..."
codesign --verify --verbose=1 "$APP_PATH"

echo "==> Build successful: $APP_PATH"

if [[ "$DO_RUN" == true ]]; then
  echo "==> Launching $APP_NAME..."
  open "$APP_PATH"
fi
