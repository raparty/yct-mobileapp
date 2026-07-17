<p align="center">
  <img src="docs/yct_logo.png" width="100" alt="Yoga Consciousness Trust Logo"/>
</p>

<h1 align="center">Yoga Consciousness Trust</h1>
<p align="center">
  <strong>Official Mobile Application</strong><br/>
  అనుష్ఠాన యోగ వేదాంత మాస పత్రిక<br/>
  Spreading the light of Anushtana Yoga Vedanta since 1990<br/>
  <a href="https://www.yogaconsciousness.org">yogaconsciousness.org</a>
</p>

---

> ⚠️ **Proprietary Software — All Rights Reserved**
> Copyright © Yoga Consciousness Trust. Unauthorised use, reproduction, or distribution is strictly prohibited. See [License](#license) below.

---

## ✨ Features

- 📰 **Magazine Library** — Complete archive of *Yoga Chaitanya Prabha* (యోగ చైతన్య ప్రభ)
- 🎵 **Audio Discourses** — Stream Gurudev's teachings with in-app player, search, skip controls
- 📚 **Books & Publications** — Telugu, English, and bilingual books with in-app PDF reader
- 📍 **Centers Directory** — All 15 centers across AP & Telangana with tap-to-call and Maps
- 💬 **Daily Teaching** — A fresh teaching from Gurudev each day
- 👤 **About Gurudev** — Life and teachings of Yogacharya Sri Raparthi Rama Rao

---

## 🏗️ Architecture

```
Flutter App (Android + iOS)
       ↓
Firebase Firestore ← content metadata (titles, paths, settings)
       +
Cloudflare R2      ← actual files (PDFs, MP3s)
       ↑
Admin Panel (Cloudflare Worker) ← one-click upload for YCT staff
```

| Layer | Technology | Purpose |
|-------|-----------|---------|
| App | Flutter 3.19 | Single codebase → Android + iOS |
| Database | Firebase Firestore | Real-time content management |
| Storage | Cloudflare R2 | Secure PDF and MP3 hosting |
| Admin | Cloudflare Worker | Authorised staff content publishing |
| CI/CD | GitHub Actions | Automatic APK + AAB builds |

---

## 🚀 Building (Authorised Developers Only)

```bash
git clone https://github.com/raparty/yct-mobileapp.git
cd yct-mobileapp
flutter pub get
flutter run
```

> Firebase and Cloudflare credentials are required.
> Contact **info@yogaconsciousness.org** for access.

---

## 📦 Automated Builds

Every push to `main` builds these artifacts automatically via GitHub Actions:

| Artifact | Description | Size |
|----------|-------------|------|
| `yct-arm64-apk` | Modern Android phones | ~9 MB |
| `yct-arm32-apk` | Older Android phones | ~8 MB |
| `yct-playstore-aab` | Google Play Store bundle | ~22 MB |
| `yct-ios-unsigned` | iOS unsigned build | — |

---

## 📂 Project Structure

```
lib/
├── main.dart                         # App entry + Firebase init
├── core/
│   ├── constants.dart                # Colors, strings, config
│   ├── models.dart                   # Magazine, Book, AudioTrack
│   └── firestore_service.dart        # Firestore data fetching
└── screens/
    ├── home_screen.dart              # Home with daily quote
    ├── library_screen.dart           # Publications browser
    ├── magazine_archive_screen.dart  # Browse by year
    ├── issue_detail_screen.dart      # Issue detail + PDF viewer
    ├── book_detail_screen.dart       # Book detail + PDF viewer
    ├── pdf_viewer_screen.dart        # In-app PDF reader
    ├── audio_screen.dart             # Audio player
    ├── centers_screen.dart           # All 15 centers
    ├── gurudev_screen.dart           # About Gurudev
    └── more_screen.dart              # Settings and links
```

---

## 📍 Centers

| City | Name | Phone |
|------|------|-------|
| Vizinigiri (HQ) | Yoga Chaitanyaramam | +91 8966 268923 |
| Bheemili | International Institute of Yoga Research & Training | +91 8933 228222 |
| Visakhapatnam | Yoga Consciousness Trust (3 centers) | +91 9440 179914 |
| Hyderabad | Yoga Chaitanya Sadanam | +91 8415 329306 |
| Nandyal | Yoga Chaitanya Kendra | +91 8919 771823 |
| Kanavaram | Yoga Consciousness Trust | +91 9949 203222 |
| Kakinada | Yoga Consciousness Trust | +91 9849 340359 |
| Rajahmundry | Yoga Consciousness Trust | +91 7382 308440 |
| Eluru | Yoga Consciousness Trust | +91 9491 606925 |

---

## 📞 Contact

**Yoga Consciousness Trust**
Yoga Chaitanyaramam, Vizinigiri – 535 250, Jami Mandal, Vizianagaram Dt., A.P.

📧 info@yogaconsciousness.org
🌐 www.yogaconsciousness.org
📞 +91 8966 268923

---

## License

**Copyright © 2026 Yoga Consciousness Trust. All Rights Reserved.**

This software and its source code are the exclusive property of Yoga Consciousness Trust (YCT), Vizinigiri, Andhra Pradesh, India.

**You may NOT:**
- Copy, modify, or distribute this software
- Use this code for any commercial or non-commercial purpose without written permission
- Reverse engineer or create derivative works based on this software

**You may:**
- View this code for reference only, with prior written consent from YCT

For permissions or enquiries: **info@yogaconsciousness.org**

*This repository is hosted publicly for deployment and CI/CD purposes only.*
