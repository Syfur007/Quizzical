# Quizzical

A lightweight, engaging Flutter quiz app that lets users pick categories, choose quiz length and difficulty, answer questions, and get an encouraging, motivational summary at the end.

This README describes the app, how to run it, and shows screenshots from the current build.

## Key features

- Category-based quizzes with configurable number of questions and difficulty.
- Immediate feedback for correct and incorrect answers.
- Summary score screen with a short, highly motivational quote encouraging the player to play again.
- Clean, responsive UI with SVG assets scaled for different screen sizes.
- Cross-platform: Android, iOS, macOS, Linux, Windows.

## Files of interest

- `lib/main.dart` — app entrypoint.
- `lib/screens/` — UI screens (home, categories, quiz, results, config).
- `assets/images/` — SVG icons used by the UI.
- `screenshot/android/` — example screenshots used below.

## Screenshots

Home

![Home screenshot](screenshot/android/home.png)

Categories

![Categories screenshot](screenshot/android/categories.png)

Quiz configuration (example 1)

![Quiz configure 1](screenshot/android/quiz_configure1.png)

Quiz configuration (example 2)

![Quiz configure 2](screenshot/android/quiz_configure2.png)

Correct answer feedback

![Correct answer](screenshot/android/correct_answer.png)

Wrong answer feedback

![Wrong answer](screenshot/android/wrong_answer.png)

Score — excellent

![Score excellent](screenshot/android/score_excellent.png)

Score — not bad

![Score not bad](screenshot/android/score_notbad.png)

Score — keep trying

![Score keep trying](screenshot/android/score_keeptrying.png)

> Note: If images do not display in your environment (for example some Git hosts require special handling), open the referenced files directly under `screenshot/android/`.

## Getting started (development)

Prerequisites: Flutter SDK installed and configured for your target platforms. See https://flutter.dev/docs/get-started/install.

From the project root run:

```bash
flutter pub get
flutter run
```

To run on a specific device/emulator:

```bash
flutter devices  # list devices
flutter run -d <device-id>
```

If Android build fails due to a missing MainActivity on older projects, ensure `android/app/src/main/kotlin/com/example/quizzical/MainActivity.kt` exists with:

```kotlin
package com.example.quizzical

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

## Contributing

Contributions are welcome. Open an issue or submit a pull request for bug fixes, UI improvements, or additional features (more categories, question sources, analytics, etc.).

## License

This project does not include a license file. Add a `LICENSE` if you intend to publish or share the app under a specific license.
