#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
CONFIGURATION="release"
if [[ "$MODE" == "--debug" || "$MODE" == "debug" ]]; then
  CONFIGURATION="debug"
fi

PRODUCT_NAME="BaziChart"
APP_DISPLAY_NAME="八字排盘"
BUNDLE_ID="app.bazichart.macos"
MIN_SYSTEM_VERSION="26.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_DISPLAY_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$PRODUCT_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"

pkill -x "$PRODUCT_NAME" >/dev/null 2>&1 || true

swift build -c "$CONFIGURATION"
BIN_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path)"
BUILD_BINARY="$BIN_DIR/$PRODUCT_NAME"
RESOURCE_BUNDLE="$BIN_DIR/${PRODUCT_NAME}_${PRODUCT_NAME}.bundle"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

if [[ ! -d "$RESOURCE_BUNDLE" ]]; then
  echo "missing SwiftPM resource bundle: $RESOURCE_BUNDLE" >&2
  exit 1
fi
cp -R "$RESOURCE_BUNDLE" "$APP_BUNDLE/"

build_icon() {
  local source_icon="$ROOT_DIR/Resources/AppIcon.png"
  local iconset="$DIST_DIR/AppIcon.iconset"

  [[ -f "$source_icon" ]] || return 0
  rm -rf "$iconset"
  mkdir -p "$iconset"
  sips -z 16 16 "$source_icon" --out "$iconset/icon_16x16.png" >/dev/null
  sips -z 32 32 "$source_icon" --out "$iconset/icon_16x16@2x.png" >/dev/null
  sips -z 32 32 "$source_icon" --out "$iconset/icon_32x32.png" >/dev/null
  sips -z 64 64 "$source_icon" --out "$iconset/icon_32x32@2x.png" >/dev/null
  sips -z 128 128 "$source_icon" --out "$iconset/icon_128x128.png" >/dev/null
  sips -z 256 256 "$source_icon" --out "$iconset/icon_128x128@2x.png" >/dev/null
  sips -z 256 256 "$source_icon" --out "$iconset/icon_256x256.png" >/dev/null
  sips -z 512 512 "$source_icon" --out "$iconset/icon_256x256@2x.png" >/dev/null
  sips -z 512 512 "$source_icon" --out "$iconset/icon_512x512.png" >/dev/null
  cp "$source_icon" "$iconset/icon_512x512@2x.png"
  iconutil -c icns "$iconset" -o "$APP_RESOURCES/AppIcon.icns"
  rm -rf "$iconset"
}

build_icon

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$PRODUCT_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>NSSupportsAutomaticGraphicsSwitching</key>
  <true/>
</dict>
</plist>
PLIST

verify_bundle() {
  test -x "$APP_BINARY"
  test -f "$INFO_PLIST"
  test -d "$APP_BUNDLE/${PRODUCT_NAME}_${PRODUCT_NAME}.bundle"
  test -f "$APP_BUNDLE/${PRODUCT_NAME}_${PRODUCT_NAME}.bundle/AreaIndex.json"
  plutil -lint "$INFO_PLIST" >/dev/null
}

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  build|--build)
    verify_bundle
    echo "Built $APP_BUNDLE"
    ;;
  run)
    verify_bundle
    open_app
    ;;
  --debug|debug)
    verify_bundle
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    verify_bundle
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$PRODUCT_NAME\""
    ;;
  --verify|verify)
    verify_bundle
    open_app
    sleep 1
    pgrep -x "$PRODUCT_NAME" >/dev/null
    echo "Verified $APP_BUNDLE"
    ;;
  *)
    echo "usage: $0 [run|build|--debug|--logs|--verify]" >&2
    exit 2
    ;;
esac
