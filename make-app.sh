#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")"

echo "=== 编译 release ==="
swift build -c release

echo "=== 打包 .app ==="
rm -rf build/7zzGUI.app
mkdir -p build/7zzGUI.app/Contents/{MacOS,Resources}
cp .build/release/7zzGUI build/7zzGUI.app/Contents/MacOS/
cp Sources/7zzGUI/Info.plist build/7zzGUI.app/Contents/ 2>/dev/null || true

# Bundle 7zz binary
echo "  封装 7zz:"
cp 7zz build/7zzGUI.app/Contents/Resources/7zz
chmod +x build/7zzGUI.app/Contents/Resources/7zz

# Bundle language files into .app Resources
echo "  复制语言文件到 .app/Contents/Resources/language/ ..."
cp -r Sources/7zzGUI/Resources/language build/7zzGUI.app/Contents/Resources/language

# Bundle SPM resource bundle (for Bundle.module fallback)
echo "  复制 SPM 资源包..."
if [ -d ".build/release/7zzGUI_7zzGUI.bundle" ]; then
    cp -r .build/release/7zzGUI_7zzGUI.bundle build/7zzGUI.app/Contents/MacOS/
fi

# Generate icon from source PNG (centered in square, no stretching)
if [ -f 7ziplogo.png ]; then
    echo "  从 7ziplogo.png 生成图标..."
    rm -rf build/icon.iconset && mkdir -p build/icon.iconset

    python3 -c "
from PIL import Image
src = Image.open('7ziplogo.png').convert('RGBA')
w, h = src.size
s = max(w, h)
# Create square transparent canvas, centered
canvas = Image.new('RGBA', (s, s), (0, 0, 0, 0))
canvas.paste(src, ((s - w) // 2, (s - h) // 2))

for size in [16, 32, 128, 256, 512]:
    for suffix in [(size, ''), (size * 2, '@2x')]:
        sz, sfx = suffix
        resized = canvas.resize((sz, sz), Image.LANCZOS)
        resized.save(f'build/icon.iconset/icon_{size}x{size}{sfx}.png')
        print(f'  {size}x{size}{sfx}')
"

    iconutil -c icns build/icon.iconset -o build/7zzGUI.app/Contents/Resources/AppIcon.icns 2>/dev/null || true
fi

touch build/7zzGUI.app

echo "=== 完成 ==="
ls -lh build/7zzGUI.app/Contents/MacOS/7zzGUI
echo "  7zz: $(ls -lh build/7zzGUI.app/Contents/Resources/7zz | awk '{print $5}')"
echo ""
echo "使用: open build/7zzGUI.app"
echo "复制到 Applications: cp -r build/7zzGUI.app /Applications/"
