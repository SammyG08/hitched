# Hitched mobile app

Flutter client for the Hitched Django REST API.

## Run locally

Start Django so it accepts emulator traffic:

```powershell
cd C:\wedding-app-backend
.\.venv\Scripts\python.exe manage.py runserver 0.0.0.0:8000
```

The Android emulator uses the default API URL:

```powershell
flutter run
```

Override the URL for iOS Simulator or a physical device:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

For a physical phone, replace `127.0.0.1` with the computer's LAN address.

## Source layout

- `lib/app`: application root
- `lib/core`: configuration, routing, networking, storage, errors, and theme
- `lib/features`: domain features such as authentication
- `lib/shared`: reusable presentation widgets
- `test`: unit and widget tests
