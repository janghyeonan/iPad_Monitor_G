#!/bin/zsh
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /absolute/path/to/icon-1024.png"
  exit 1
fi

SRC="$1"
if [[ ! -f "$SRC" ]]; then
  echo "File not found: $SRC"
  exit 1
fi

APPICON_DIR="/Users/minju/Documents/iPad_Monitor_G/iPad_Monitor_G/Resources/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$APPICON_DIR"

# iPad icon slots + App Store marketing icon
specs=(
  "40 icon-20x20@2x.png"
  "58 icon-29x29@2x.png"
  "80 icon-40x40@2x.png"
  "152 icon-76x76@2x.png"
  "167 icon-83.5x83.5@2x.png"
  "1024 icon-1024x1024@1x.png"
)

for spec in "${specs[@]}"; do
  size="${spec%% *}"
  name="${spec#* }"
  sips -z "$size" "$size" "$SRC" --out "$APPICON_DIR/$name" >/dev/null
done

echo "App icon images generated in: $APPICON_DIR"
