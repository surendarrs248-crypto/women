#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

flutter build apk --release
flutter build web --release
install -D -m 0644 \
  build/app/outputs/flutter-apk/app-release.apk \
  build/web/sakhi.apk