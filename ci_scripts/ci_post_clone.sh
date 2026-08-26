#!/bin/sh
set -e

echo "=== Installing Flutter ==="
git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  -b stable \
  "$HOME/flutter"

export PATH="$PATH:$HOME/flutter/bin"

echo "=== Flutter version ==="
flutter --version

echo "=== Flutter pub get ==="
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

echo "=== Flutter generate iOS config ==="
flutter build ios --config-only --release

echo "=== Installing CocoaPods ==="
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install --repo-update

echo "=== Done ==="
