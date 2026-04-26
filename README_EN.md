# HoyoBrowser

> macOS floating browser, designed for grinding miHoYo games while watching guides. Control playback with keyboard shortcuts.

[\[简体中文\]](README.md) [\[English\]](README_EN.md)

## Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd + Shift + P` | Play / Pause video |
| `Cmd + Shift + →` | Seek forward 5s |
| `Cmd + Shift + ←` | Seek backward 5s |
| `Cmd + Shift + H` | Hide / Show window |
| `Cmd + Shift + O` | Focus address bar |

## Installation

### Download DMG

Download `HoyoBrowser.dmg` from [Releases](https://github.com/wait1nGGG/HoyoBrowser/releases), then drag `HoyoBrowser.app` into the `Applications` folder.

### Build from source

```bash
chmod +x build.sh
./build.sh
open build/HoyoBrowser.app
```

## Usage

- Opens Bilibili by default; enter any URL in the address bar
- Click 📌 button next to the address bar to toggle always-on-top
- Left-click 🌐 in the menu bar to show/hide the window
- Right-click 🌐 for menu: open URL, go home, quit
- Close button hides the window; quit via the menu bar icon

## Tech Stack

- Swift + AppKit + WKWebView
- Global hotkeys: Carbon `RegisterEventHotKey`
- Cookie storage: `WKWebsiteDataStore.default()` persisted to disk
- Video control: JavaScript injection to control `<video>` elements

## Requirements

- macOS 13.0 or later
