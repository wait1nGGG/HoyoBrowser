#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="HoyoBrowser"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
SOURCES_DIR="$PROJECT_DIR/Sources"

echo "=== HoyoBrowser 构建脚本 ==="
echo ""

# 清理旧构建
rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 编译 Swift 源码
echo "编译 Swift 源码..."
swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    "$SOURCES_DIR/main.swift" \
    "$SOURCES_DIR/AppDelegate.swift" \
    "$SOURCES_DIR/HotkeyManager.swift" \
    "$SOURCES_DIR/StatusBarController.swift" \
    "$SOURCES_DIR/BrowserWindowController.swift" \
    "$SOURCES_DIR/WebViewController.swift" \
    -framework Cocoa \
    -framework WebKit \
    -framework Carbon \
    -O

echo "编译完成"

# 复制 Info.plist
cp "$SOURCES_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# 创建简单的应用图标（如果没有自定义图标）
if [ ! -f "$SOURCES_DIR/AppIcon.icns" ]; then
    echo "生成默认图标..."
    # 创建一个简单的纯色 PNG 作为图标
    ICON_DIR="$BUILD_DIR/icon_tmp"
    mkdir -p "$ICON_DIR"

    # 使用 sips 创建简单图标
    python3 -c "
import struct, zlib

def create_png(width, height, color):
    def chunk(ctype, data):
        c = ctype + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)

    header = b'\\x89PNG\\r\\n\\x1a\\n'
    ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0))
    raw = b''
    for y in range(height):
        raw += b'\\x00' + bytes(color * width)
    idat = chunk(b'IDAT', zlib.compress(raw))
    iend = chunk(b'IEND', b'')
    return header + ihdr + idat + iend

# 创建蓝色调的图标 128x128
png_data = create_png(128, 128, [64, 128, 255])
with open('$ICON_DIR/icon_128.png', 'wb') as f:
    f.write(png_data)

# 创建不同尺寸
for size in [16, 32, 256]:
    png_data = create_png(size, size, [64, 128, 255])
    with open(f'$ICON_DIR/icon_{size}.png', 'wb') as f:
        f.write(png_data)
" 2>/dev/null || echo "Python3 不可用，跳过图标生成"

    # 尝试用 sips 转换或使用 iconutil
    if [ -f "$ICON_DIR/icon_128.png" ]; then
        mkdir -p "$ICON_DIR/iconset"
        cp "$ICON_DIR/icon_16.png" "$ICON_DIR/iconset/icon_16x16.png"
        cp "$ICON_DIR/icon_32.png" "$ICON_DIR/iconset/icon_16x16@2x.png"
        cp "$ICON_DIR/icon_32.png" "$ICON_DIR/iconset/icon_32x32.png"
        cp "$ICON_DIR/icon_128.png" "$ICON_DIR/iconset/icon_128x128.png"
        cp "$ICON_DIR/icon_256.png" "$ICON_DIR/iconset/icon_128x128@2x.png"
        cp "$ICON_DIR/icon_256.png" "$ICON_DIR/iconset/icon_256x256.png"

        iconutil -c icns -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns" "$ICON_DIR/iconset" 2>/dev/null || \
            cp "$ICON_DIR/icon_128.png" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    fi

    rm -rf "$ICON_DIR"
else
    cp "$SOURCES_DIR/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

echo ""
echo "=== 构建完成 ==="
echo "App 路径: $APP_BUNDLE"
echo ""
echo "运行方式:"
echo "  open \"$APP_BUNDLE\""
echo ""
echo "注意事项:"
echo "  1. 首次启动后，应用图标会出现在菜单栏（不是 Dock）"
echo "  2. 快捷键:"
echo "     - Cmd+Shift+P  播放/暂停"
echo "     - Cmd+Shift+→  快进 5 秒"
echo "     - Cmd+Shift+←  快退 5 秒"
echo "     - Cmd+Shift+H  隐藏/显示"
echo "     - Cmd+Shift+O  聚焦地址栏"
echo ""
