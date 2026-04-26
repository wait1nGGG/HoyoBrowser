# HoyoBrowser

macOS 浮动迷你浏览器，专为一边工作一边看视频设计。始终可通过快捷键控制播放。

## 特性

- **浮动窗口** — 窗口可一键置顶于所有应用之上，不会在工作时被遮挡
- **菜单栏运行** — 不占用 Dock 空间，仅在菜单栏显示 🌐 图标
- **全局快捷键** — 即使浏览器在后台也能控制视频播放
- **跨空间显示** — 切换桌面或全屏应用时窗口跟随
- **Cookie 持久化** — 登录状态、偏好设置在重启后保留

## 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Cmd + Shift + P` | 播放 / 暂停视频 |
| `Cmd + Shift + →` | 快进 5 秒 |
| `Cmd + Shift + ←` | 快退 5 秒 |
| `Cmd + Shift + H` | 隐藏 / 显示窗口 |
| `Cmd + Shift + O` | 聚焦地址栏 |

## 安装

### 方式一：下载 DMG

从 [Releases](https://github.com/your-username/hoyobrowser/releases) 下载 `HoyoBrowser.dmg`，将 `HoyoBrowser.app` 拖入 `应用程序` 文件夹。

### 方式二：从源码构建

```bash
chmod +x build.sh
./build.sh
open build/HoyoBrowser.app
```

## 操作说明

- 默认打开 Bilibili，可在地址栏输入任意网址
- 地址栏旁 📌 图钉按钮可切换窗口置顶
- 菜单栏点击 🌐 切换窗口显示/隐藏
- 右键 🌐 菜单可打开 URL、回到首页、退出
- 关闭按钮仅隐藏窗口，退出请通过菜单栏菜单

## 技术栈

- Swift + AppKit + WKWebView
- 全局快捷键：Carbon `RegisterEventHotKey`
- Cookie 存储：`WKWebsiteDataStore.default()` 持久化到磁盘
- 视频控制：JavaScript 注入操控 `<video>` 元素

## 系统要求

- macOS 13.0 及以上
