#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="HoyoBrowser"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_DIR="$BUILD_DIR/dmg"
DMG_FILE="$BUILD_DIR/$APP_NAME.dmg"

echo "=== 制作 $APP_NAME DMG 安装包 ==="
echo ""

# 先确保已构建
if [ ! -d "$APP_BUNDLE" ]; then
    echo "未找到 .app，先执行构建..."
    "$PROJECT_DIR/build.sh"
fi

# 清理 DMG 临时目录
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# 复制 .app
cp -R "$APP_BUNDLE" "$DMG_DIR/"

# 创建 Applications 快捷方式
ln -s /Applications "$DMG_DIR/Applications"

# 创建 DMG
echo "创建 DMG..."
rm -f "$DMG_FILE"

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_FILE"

# 清理
rm -rf "$DMG_DIR"

echo ""
echo "=== DMG 创建完成 ==="
echo "文件: $DMG_FILE"
echo ""
echo "双击打开 DMG，将 $APP_NAME.app 拖入 Applications 文件夹即可安装。"
echo ""
