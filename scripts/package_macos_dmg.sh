#!/usr/bin/env bash
set -euo pipefail

# Package macOS DMGs for Apple Silicon (arm64), Intel (x86_64), and Universal
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="LingoDiff Studio"
SOURCE_APP="${1:-${PROJECT_ROOT}/build/macos/Build/Products/Release/translation.app}"
DIST_DIR="${PROJECT_ROOT}/dist"
BUILD_TEMP="/tmp/lingodiff_packaging_$$"

if [ ! -d "$SOURCE_APP" ]; then
  echo "Error: Source app bundle not found at '$SOURCE_APP'."
  echo "Please run 'flutter build macos --release' first."
  exit 1
fi

echo "=========================================="
echo "Packaging ${APP_NAME} macOS DMGs"
echo "Source: ${SOURCE_APP}"
echo "Output: ${DIST_DIR}"
echo "=========================================="

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
rm -rf "$BUILD_TEMP"
mkdir -p "$BUILD_TEMP"

cleanup() {
  rm -rf "$BUILD_TEMP"
}
trap cleanup EXIT

thin_bundle() {
  local target_arch="$1"
  local app_bundle="$2"
  
  echo "Thinning bundle to arch: ${target_arch}..."
  while IFS= read -r f; do
    if file -b "$f" | grep -q "Mach-O"; then
      if lipo -info "$f" | grep -q "${target_arch}"; then
        lipo -thin "${target_arch}" "$f" -output "${f}.tmp"
        mv "${f}.tmp" "$f"
      fi
    fi
  done < <(find "$app_bundle" -type f)

  echo "Re-signing ${target_arch} bundle..."
  codesign --force --deep --sign - "$app_bundle"
  codesign --verify --deep --strict "$app_bundle"
}

create_dmg() {
  local arch_name="$1"
  local app_src="$2"
  local dmg_name="LingoDiff-macOS-${arch_name}.dmg"
  local staging_dir="${BUILD_TEMP}/staging_${arch_name}"
  
  echo "Creating DMG for ${arch_name}..."
  mkdir -p "$staging_dir"
  cp -R "$app_src" "${staging_dir}/${APP_NAME}.app"
  ln -s /Applications "${staging_dir}/Applications"
  
  hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "$staging_dir" \
    -ov \
    -format UDZO \
    "${DIST_DIR}/${dmg_name}" >/dev/null

  echo "✓ Created ${DIST_DIR}/${dmg_name}"
}

# 1. Apple Silicon (arm64)
echo "------------------------------------------"
echo "1. Building Apple Silicon (arm64) DMG..."
ARM64_APP="${BUILD_TEMP}/arm64.app"
cp -R "$SOURCE_APP" "$ARM64_APP"
thin_bundle "arm64" "$ARM64_APP"
create_dmg "arm64" "$ARM64_APP"

# 2. Intel (x86_64)
echo "------------------------------------------"
echo "2. Building Intel (x86_64) DMG..."
X86_APP="${BUILD_TEMP}/x86_64.app"
cp -R "$SOURCE_APP" "$X86_APP"
thin_bundle "x86_64" "$X86_APP"
create_dmg "x86_64" "$X86_APP"

# 3. Universal (arm64 + x86_64)
echo "------------------------------------------"
echo "3. Building Universal DMG..."
UNIVERSAL_APP="${BUILD_TEMP}/universal.app"
cp -R "$SOURCE_APP" "$UNIVERSAL_APP"
codesign --force --deep --sign - "$UNIVERSAL_APP"
create_dmg "universal" "$UNIVERSAL_APP"

# 4. Generate Checksums
echo "------------------------------------------"
echo "Generating SHA256 checksums..."
cd "$DIST_DIR"
shasum -a 256 *.dmg > SHA256SUMS.txt
cat SHA256SUMS.txt

echo "=========================================="
echo "Packaging complete! Artifacts:"
ls -lh "$DIST_DIR"
echo "=========================================="
