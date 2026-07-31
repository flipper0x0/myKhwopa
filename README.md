<div align="center">
  <img width="180" height="180" alt="myKhwopa Logo" src="https://github.com/user-attachments/assets/a9ad1791-9a39-45b8-b21a-29bcaede0bcf" />

  # myKhwopa

  > **This APP include all features that official Khwopa EMIS app provide. And also include some Exclusive extra features.**  
  > Blazing fast | Offline | Complete EMIS App 

  <p align="center">
    <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="GitHub stars" src="https://img.shields.io/github/stars/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="GitHub forks" src="https://img.shields.io/github/forks/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="License" src="https://img.shields.io/github/license/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white">
    <img alt="Last Commit" src="https://img.shields.io/github/last-commit/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="Platform" src="https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white">
  </p>

<p align="center">
  <a href="https://github.com/flipper0x0/KhCE_Student_App/releases/latest">
    <img src="https://img.shields.io/badge/⬇_DOWNLOAD_APK-FF3D00?style=for-the-badge&logo=android&logoColor=white" alt="Download APK">
  </a>
</p>

<p align="center">
  <a href="https://github.com/flipper0x0/KhCE_Student_App/issues/new?template=bug_report.md">🐛 Report Bug</a>
  •
  <a href="https://github.com/flipper0x0/KhCE_Student_App/issues/new?template=feature_request.md">✨ Request Feature</a>
</p>
</div>

---

## 📖 Table of Contents
- [Why This Exists](#-why-this-exists)
- [Demo](#-demo)
- [Features](#-features)
- [Installation](#-installation)
- [Build From Source](#-build-from-source)
- [Tech Stack](#️-tech-stack)
- [Roadmap](#️-roadmap)
- [Contributing](#-contributing)
- [Legal](#️-legal-disclaimer)

---

## 🔥 Why This Exists

The official Khwopa College app was **slow and broken** ; lacks features like invoices, offline-support, notice etc.

**myKhwopa** is the fix. Built by a KhCE student, for KhCE students. A Material 3, offline-first, zero unnecessary permissions & analytics, and actually pleasant to use.

---

## 🎬 Demo

<!-- ADD A GIF HERE — record your screen with scrcpy or Android Studio emulator, convert to GIF with ezgif.com -->
> 📸 *Screenshots below — GIF demo coming soon*

<div align="center">
  <img width="220" alt="Home Screen" src="https://github.com/user-attachments/assets/a0956c4f-6995-4e42-aaa2-f80957e8283a" />
  <img width="220" alt="Attendance View" src="https://github.com/user-attachments/assets/d5318547-ca17-4924-8de5-5b0d5edb562c" />
  <img width="220" alt="Invoice Screen" src="https://github.com/user-attachments/assets/e96b3549-ba47-4a87-87bc-91cc21ef26bb" />
</div>

<details>
<summary>📸 More Screenshots</summary>
<br>
<div align="center">
  <img width="220" alt="Syllabus" src="https://github.com/user-attachments/assets/32e4a2a2-7d95-4b97-8ec5-2278f9b8e804" />
  <img width="220" alt="Dark Mode" src="https://github.com/user-attachments/assets/db9aeebb-1b67-4afe-a47e-1c432a6c2874" />
  <img width="220" alt="Settings" src="https://github.com/user-attachments/assets/ce4b1e9b-32c1-41ac-ab55-c1cca53b38b3" />
</div>
</details>

---


## ✨ Features
`Covers Almost every features that you need.`
<details>

| Feature | Status |
|---|---|
| 📊 Real-time attendance| ✅ Live |
| 💰 Invoice & payment history | ✅ Live |
| 📚 Full syllabus with offline support | ✅ Live |
| 🌙 Dark / Light mode | ✅ Live |
| ⚡ Works offline | ✅ Live |
| 🔒 API rate limiting (server-friendly) | ✅ Live |
| 🎨 Material 3 design + smooth animations | ✅ Live |
| 🔔 Push notifications  | ✅ Live |
| 📈 GPA calculator & result analysis | ✅ Live |
| 📖 Peer-to-peer note sharing | 📋 Planned |
| 🍎 iOS support | 📋 Planned (need Mac) |

</details>
---

## 📥 Installation

### Option 1: Direct APK (Recommended for users)

1. Download the latest APK from **[Releases](https://github.com/flipper0x0/KhCE_Student_App/releases/latest)**
2. On your Android device: **Settings → Security → Install Unknown Apps → Enable**
3. Open the downloaded `.apk` and install
4. Login with your Khwopa student credentials

> ⚠️ **Minimum:** Android 6.0 (API 23) or higher

---

## 🛠️ Build From Source

> For developers who want to run or contribute to the project.
<details>
<summary>Expand</summary>
<br>
**Prerequisites:**
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code
- Android emulator or physical device (API 23+)

```bash
# 1. Clone the repo
git clone https://github.com/flipper0x0/KhCE_Student_App.git
cd KhCE_Student_App

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# 4. Build release APK
flutter build apk --release
```

</details>
---

## ⚠️ Known Limitations

- **Android only** — No Mac = no iOS builds (sponsors welcome 👀)
- **Read-only invoices** — Can't process payments through the app
- **Push notifications** — Firebase setup in progress; support global push but no custom Departmental wise notice/user based
- **No biometric auth** — Planned for next major release
- **Data accuracy** — Dependent on Khwopa's/IOE backend uptime; always verify critical info officially

---

## 🗺️ Roadmap

- [x] Offline-first architecture with local caching
- [x] Dark mode
- [x] Push notifications (Firebase FCM)
- [x] GPA calculator & result analysis
- [x] Study material repository
- [ ] iOS support

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome. Just frok and create PR.

**Contact:**
- 📧 Email: [flipper0x0@proton.me](mailto:flipper0x0@proton.me)
- 🐛 Issues: [GitHub Issues](https://github.com/flipper0x0/KhCE_Student_App/issues)

---

## ⚖️ Legal Disclaimer

**Unofficial Third-Party Application**  
This app is NOT affiliated with, endorsed by, or officially connected to Khwopa College of Engineering.

**Intellectual Property**  
All logos, branding, trademarks, and backend data belong to Khwopa College of Engineering. This app provides an alternative interface to publicly accessible data.

**Liability & Data Accuracy**  
Provided "as is" without warranties. Data may be inaccurate, outdated, or incomplete. Always verify critical information (attendance, fees, exam schedules) through official college channels.

**Use at Your Own Risk**  
Developers assume no responsibility for consequences arising from use or misuse, including data inaccuracies, missed deadlines, or account issues.

**Educational Purpose**  
Created to improve student experience. If Khwopa College requests removal, this repository will be taken down immediately.

---

<div align="center">
  
**Built with ❤️ using Flutter**

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Made in Nepal](https://img.shields.io/badge/Made%20in-Nepal-red?style=flat-square)](https://en.wikipedia.org/wiki/Nepal)

**Not officially affiliated with Khwopa College of Engineering**

[⬆ Back to Top](#mykhwopa)

</div>