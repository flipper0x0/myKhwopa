<div align="center">
  <img width="200" height="200" alt="myKhwopa Logo" src="https://github.com/user-attachments/assets/a9ad1791-9a39-45b8-b21a-29bcaede0bcf" />
  
  # myKhwopa
  
  **A faster, cleaner mobile app for Khwopa students.**  
  Built with Flutter because the official app wasn't cutting it.
  
  <p align="center">
    <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="GitHub stars" src="https://img.shields.io/github/stars/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="GitHub forks" src="https://img.shields.io/github/forks/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="License" src="https://img.shields.io/github/license/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
    <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white">
    <img alt="Last Commit" src="https://img.shields.io/github/last-commit/flipper0x0/KhCE_Student_App?style=flat-square&color=5865F2">
  </p>
  
  [Download APK](https://github.com/flipper0x0/KhCE_Student_App/releases) • [Report Bug](https://github.com/flipper0x0/KhCE_Student_App/issues) • [Request Feature](https://github.com/flipper0x0/KhCE_Student_App/issues)
</div>

---

## 🚀 Why This Exists

The official Khwopa app was slow, outdated, and frustrating to use. This is the fix—Material 3 design, local caching, and an interface that actually works.

## ✨ Features

**Core Functionality:**
- 📊 Real-time attendance tracking with visual analytics
- 💰 Invoice viewing and payment history (read-only)
- 📚 Complete syllabus access with offline support
- 🌙 Dark mode that doesn't burn your eyes
- ⚡ Lightning-fast local caching for offline use
- 🔒 Rate limiting to keep college servers happy

**User Experience:**
- Material 3 design language
- Smooth animations and transitions
- One-handed navigation
- No unnecessary permissions
- Battery-efficient background sync

## 📱 Previews

<div align="center">
  <img width="250" alt="Home Screen" src="https://github.com/user-attachments/assets/a0956c4f-6995-4e42-aaa2-f80957e8283a" />
  <img width="250" alt="Attendance View" src="https://github.com/user-attachments/assets/d5318547-ca17-4924-8de5-5b0d5edb562c" />
  <img width="250" alt="Invoice Screen" src="https://github.com/user-attachments/assets/e96b3549-ba47-4a87-87bc-91cc21ef26bb" />
</div>

<details>
<summary>📸 View More Screenshots</summary>
<br>
<div align="center">
  <img width="250" alt="Syllabus" src="https://github.com/user-attachments/assets/32e4a2a2-7d95-4b97-8ec5-2278f9b8e804" />
  <img width="250" alt="Dark Mode" src="https://github.com/user-attachments/assets/db9aeebb-1b67-4afe-a47e-1c432a6c2874" />
  <img width="250" alt="Settings" src="https://github.com/user-attachments/assets/ce4b1e9b-32c1-41ac-ab55-c1cca53b38b3" />
</div>
</details>

## 📥 Installation

### Option 1: Download APK (Recommended)
1. Go to [Releases](https://github.com/flipper0x0/KhCE_Student_App/releases)
2. Download the latest `.apk` file
3. Enable "Install from Unknown Sources" in Android settings
4. Install and open the app
5. Login with your Khwopa credentials


## 🛠️ Technical Stack

**Framework:** Flutter 3.x  
**State Management:** Provider/Riverpod  
**Local Storage:** Hive (lightweight, fast NoSQL)  
**HTTP Client:** Dio with retry interceptors  
**Architecture:** Clean Architecture with Repository pattern

**Key Implementations:**
- Cooldown timers on API refresh (prevents server spam)
- Optimistic UI updates for better UX
- Automatic retry logic for failed requests
- Smart caching with TTL (Time To Live)

## ⚠️ Known Limitations

- **Android Only** - No MacBook = no iOS builds (yet)
- **No Push Notifications** -  Available soon after properly setting `firebase`
- **Read-Only Invoices** - Can't process payments, only view
- **Data Accuracy** - Depends on official backend uptime
- **No Biometric Auth** - Coming in future updates

## 🗺️ Roadmap

- [ ] iOS version (need MacBook sponsor 👀)
- [ ] Push notifications for attendance alerts
- [ ] Offline-first architecture improvements
- [ ] Result analysis and GPA calculator
- [ ] Timetable integration
- [ ] Study material repository
- [ ] Peer-to-peer note sharing

## 🤝 Contributing

Found a bug? Want to add a feature? Contributions are welcome!

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/CoolFeature`)
3. Commit changes (`git commit -m 'Add CoolFeature'`)
4. Push to branch (`git push origin feature/CoolFeature`)
5. Open a Pull Request

**Guidelines:**
- Follow existing code style
- Write meaningful commit messages
- Test thoroughly before submitting
- Update documentation if needed

## 📞 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/flipper0x0/myKhwopa/issues)
- **Discussions:** [GitHub Discussions](https://github.com/flipper0x0/myKhwopa/discussions)
- **Email:** [flipper0x0@proton.me]

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