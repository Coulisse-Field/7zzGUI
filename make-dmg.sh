#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")"

APP="build/7zzGUI.app"
DMG="build/7zzGUI.dmg"
TMP="build/dmg_temp"

echo "=== 清理 ==="
rm -rf "$TMP" "$DMG"

echo "=== 准备 DMG 内容 ==="
mkdir -p "$TMP"
cp -R "$APP" "$TMP/"
ln -s /Applications "$TMP/Applications"

echo "=== 创建 DMG ==="
hdiutil create \
    -volname "7z GUI" \
    -fs HFS+ \
    -srcfolder "$TMP" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    "$DMG"

echo "=== 清理临时文件 ==="
rm -rf "$TMP"

echo ""
echo "=== 完成 ==="
ls -lh "$DMG"
echo ""
echo "分发: open build/"
