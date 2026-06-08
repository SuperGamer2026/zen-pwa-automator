# Zen Browser PWA Automator 🚀

An open-source, automated utility designed to instantly inject native-feeling Progressive Web App (PWA) support directly into Zen Browser.

## What It Does
* **Silent Background Setup:** Automatically fetches and installs the absolute latest secure `FirefoxPWA` x86_64 native runtime from GitHub.
* **Intelligent Link Routing:** Configures your profiles so clicking external links inside an app automatically opens back up into your main Zen workspaces instead of breaking isolation.
* **Borderless Window Management:** Injects a customized `userChrome.css` stylesheet into the runtime container to strip away legacy margins, bars, and headers for a clean aesthetic.
* **Pre-Flight Safety Check:** Verifies if Zen Browser is open before executing to prevent database or profile lock corruption.

## How to Install (One-Click Execution)

1. Press **Win + X** and open **Windows PowerShell (Admin)**.
2. Copy and paste the single line command below, then press **Enter**:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process; irm [https://raw.githubusercontent.com/SuperGamer2026/zen-pwa-automator/main/Install-ZenPWA.ps1](https://raw.githubusercontent.com/SuperGamer2026/zen-pwa-automator/main/Install-ZenPWA.ps1) | iex
