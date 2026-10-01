#!/bin/bash
set -euo pipefail
if [[ $# != 2 ]]; then
  echo "Usage: $0 /path/to/Sparkle.framework /path/to/FlutterMacOS.framework" >&2
  exit 2
fi
sparkle_dir=$(cd "$(dirname "$1")" && pwd)
flutter_dir=$(cd "$(dirname "$2")" && pwd)
package_dir=$(cd "$(dirname "$0")/.." && pwd)
xctest_dir="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/Library/Frameworks"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
xctest_lib="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/usr/lib"
mkdir -p "$test_dir/AutoUpdaterNativeTests.xctest/Contents/MacOS"
cat > "$test_dir/AutoUpdaterNativeTests.xctest/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>AutoUpdaterNativeTests</string>
<key>CFBundleIdentifier</key><string>org.hippolabs.auto-updater-native-tests</string>
<key>CFBundlePackageType</key><string>BNDL</string>
</dict></plist>
PLIST
xcrun swiftc -swift-version 5 -emit-library -module-name AutoUpdaterNativeTests \
  -I "$xctest_lib" -L "$xctest_lib" -lXCTestSwiftSupport \
  -F "$sparkle_dir" -F "$flutter_dir" -F "$xctest_dir" \
  -framework Sparkle -framework FlutterMacOS -framework XCTest \
  -Xlinker -rpath -Xlinker "$sparkle_dir" \
  -Xlinker -rpath -Xlinker "$flutter_dir" \
  -Xlinker -rpath -Xlinker "$xctest_dir" \
  -Xlinker -rpath -Xlinker "$xctest_lib" \
  "$package_dir"/macos/auto_updater_macos/Sources/auto_updater_macos/*.swift \
  "$package_dir/test/native/AutoUpdaterTests.swift" \
  -o "$test_dir/AutoUpdaterNativeTests.xctest/Contents/MacOS/AutoUpdaterNativeTests"
xcrun xctest "$test_dir/AutoUpdaterNativeTests.xctest"
