# 🪷 Yoga Consciousness Trust — Mobile App

Official app for Yoga Consciousness Trust (YCT), featuring the complete
digital library of publications, audio discourses, center directory, and
daily teachings of Yogacharya Sri Raparthi Rama Rao.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| App framework | Flutter (Android + iOS) |
| Content database | Google Sheets |
| File storage | Google Drive |
| No backend server | Direct API access |

---

## Getting Started

### Prerequisites
- Flutter SDK 3.22+ → [flutter.dev](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device

### Run locally

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/yct-app.git
cd yct-app

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Build APK for testing

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Content Management

All content is managed through Google Sheets — **no code changes needed**
to add new magazines, books, or audio.

**Google Sheet:** [YCT App Database](https://docs.google.com/spreadsheets/d/12yAED0Eo29odVliNbYKVrBD7jxlI5TCiQa_EQNX6A5s)

### Adding a new magazine issue

1. Upload the PDF to Google Drive → `YCT App Content/publications/magazines/YYYY/`
2. Name it: `YYYY-MM-MonthName.pdf` (e.g. `2026-07-July.pdf`)
3. Right-click → Share → Copy link
4. Open the Google Sheet → `magazines` tab
5. Add a new row with all details and paste the Drive link in `pdf_url`
6. Set `is_published` to `TRUE`
7. The app refreshes automatically on next open ✓

### Adding a book

Same process — upload to `books/english/` or `books/telugu/`, add row to `books` tab.

### Adding audio

Upload MP3 to `audio/discourses/`, add row to `audio` tab.

---

## Project Structure

```
lib/
├── main.dart                    # App entry + bottom navigation
├── core/
│   ├── constants.dart           # Colors, strings, Sheet config
│   ├── models.dart              # Magazine, Book, AudioTrack models
│   └── sheets_service.dart      # Google Sheets data fetching
└── screens/
    ├── home_screen.dart         # Home with daily quote
    ├── library_screen.dart      # Publications browser
    ├── magazine_archive_screen.dart  # Browse by year
    ├── issue_detail_screen.dart # Issue detail + Read/Download/Share
    ├── book_detail_screen.dart  # Book detail
    ├── audio_screen.dart        # Audio streaming
    ├── centers_screen.dart      # Center directory
    └── more_screen.dart         # About, contact links
```

---

## GitHub Actions

Every push to `main` automatically:
- Builds a debug Android APK
- Builds iOS (no code sign)
- Uploads the APK as a downloadable artifact

Download the APK from the **Actions** tab → latest build → Artifacts.

---

## Configuration

Edit `lib/core/constants.dart` to update:
- `SheetConfig.sheetId` — your Google Sheet ID
- `AppStrings` — app name, contact details
- `AppColors` — brand colors

---

*Built with ❤️ for Yoga Consciousness Trust*
