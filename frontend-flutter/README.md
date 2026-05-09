# PetroVision Flutter Frontend

PetroVision Frontend is a cross-platform Flutter application developed as part of the PetroVision smart fuel-station platform project.

The application provides:
- Customer loyalty and rewards management
- Fuel-station discovery and navigation
- Interactive maps and nearby station tracking
- QR-code point earning and redemption
- Admin dashboard access
- AI-powered analytics and recommendations
- Multilingual support (English & Arabic)
- Responsive modern UI for desktop, web, and mobile

The frontend communicates with the PetroVision FastAPI backend through REST APIs.

---

# Technologies

- Flutter
- Dart

---

# Main Features

## Admin Features

- Dashboard overview
- KPI monitoring
- Station comparison
- AI explanations
- Station analytics
- Loyalty program management
- Member management
- Reporting interface

## Customer Features

- Nearby stations
- Interactive maps
- Loyalty wallet
- Membership system
- Rewards and offers
- QR-code point earning
- QR-code reward redemption
- Transaction history
- Google Maps navigation
- Profile management

---

# Main Packages

- flutter_map
- http
- provider
- google_fonts
- latlong2
- geolocator
- url_launcher
- shared_preferences
- mobile_scanner

---

# Project Structure

```text
frontend-flutter/
│
├── lib/
│   ├── admin/
│   │   └── screens/
│   │
│   ├── auth/
│   │
│   ├── core/
│   │
│   ├── customer/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── services/
│   │
│   ├── l10n/
│   │
│   └── main.dart
│
├── assets/
│
├── pubspec.yaml
│
└── README.md
```

---

# Run Application

```bash
flutter pub get
flutter run
```

---

# Run Tests

```bash
flutter test
```

---

# Build Application

## Windows

```bash
flutter build windows
```

## Web

```bash
flutter build web
```

## Android APK

```bash
flutter build apk
```

---

# Backend Connection

The frontend connects to the FastAPI backend using REST APIs.

Default backend URL:

```dart
static const String baseUrl = "http://127.0.0.1:8000";
```

Make sure the backend server is running before launching the application.

---

# Localization

The application supports:
- English
- Arabic

Localization files are located inside:

```text
lib/l10n/
```

Language preferences are stored locally using SharedPreferences.

---

# Maps & Geolocation

PetroVision uses:
- FlutterMap
- OpenStreetMap
- Geolocator

Features include:
- Nearby station detection
- Distance calculation
- Google Maps navigation
- Interactive station previews

---

# Loyalty System

The loyalty system supports:
- Point earning
- Point redemption
- QR-code rewards
- Membership tiers:
  - Bronze
  - Silver
  - Gold

---

# Supported Platforms

- Windows Desktop
- Web
- Android Mobile

---

# Authors

PetroVision Development Team

Final Year Graduation Project  
College of Computing and Information Technology  
Information Technology Department

---

# Notes

- The backend server must be running before launching the application.
- Location access is required for nearby station features.
- Camera access may be required for QR-code scanning.
- Internet connection is required for maps and API communication.