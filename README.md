# gui-kiosk

**gui-kiosk** is a browser-accessible, headless GUI application container for Linux apps like Blender, GIMP, Inkscape, and more.  
It runs fully in Docker, streams over VNC with noVNC, and requires no desktop environment.

---

## 🚀 Features

- 💅 Run any GUI Linux app in a browser
- 🎯 No desktop required (Xvfb + x11vnc + noVNC)
- 🔐 Secure and public-ready via Traefik
- 📦 Supports dynamic APT payloads (e.g. `APP=blender`)
- 👳️ Fully containerized, reproducible, and lightweight

---

## 📦 Vendored GUI Proxy

These files are extracted on `docker build`:

- `vendor/novnc-v1.6.0.tar.gz`
- `vendor/websockify-v0.13.0.tar.gz`

---

## ⚙️ Usage

### 🔧 Build & Run

```bash
make run APP=blender
```

---

## ☕️ Support My Work

If you found **gui-kiosk** useful, inspiring, or helpful,  
consider supporting future projects:

[![Buy Me a Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=%E2%98%95&slug=bosman.solutions&button_colour=FFDD00&font_colour=000000&font_family=Arial&outline_colour=000000&coffee_colour=ffffff)](https://buymeacoffee.com/bosman.solutions)

