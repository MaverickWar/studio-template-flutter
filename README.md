# Studio template: Flutter

The starter Universal App Studio copies when someone picks **Flutter** while setting up a new project.

A Flutter app for iPhone, Android, web, Mac, Windows and Linux from one codebase, with Material 3 and a widget test. It has one change: **the look comes from `design/tokens.json`**.

- `design/tokens.json` holds the colours, fonts, corners and spacing. Studio replaces it with the project's own design straight after copying this template.
- `design/adapters/` reads those tokens in this stack's own language. See `design/adapters/README.md` once Studio has added it, or the comments at the top of each adapter.
- Style everything from the tokens. Change the look in Studio, never by typing colours into the code.

## Running it

```
flutter pub get
flutter run            # pick a phone, simulator or Chrome
```

Open the app on the device you picked.

## Checks

```
flutter analyze
flutter test
flutter build web
```

The same checks run on GitHub for every push and pull request (`.github/workflows/checks.yml`).
