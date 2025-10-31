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

<!-- Responsive thumbnails in rows; each image constrained so it won't take all vertical space -->
<div style="display:flex;flex-wrap:wrap;gap:16px;align-items:flex-start;">
  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/home.png" alt="Home screenshot" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Home</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/categories.png" alt="Categories screenshot" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Categories</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/quiz_configure1.png" alt="Quiz configure 1" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Quiz configuration (1)</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/quiz_configure2.png" alt="Quiz configure 2" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Quiz configuration (2)</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/correct_answer.png" alt="Correct answer" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Correct answer</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/wrong_answer.png" alt="Wrong answer" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Wrong answer</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/score_excellent.png" alt="Score excellent" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Score — Excellent</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/score_notbad.png" alt="Score not bad" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Score — Not bad</figcaption>
  </figure>

  <figure style="flex: 1 1 220px; max-width:260px; margin:0;">
    <img src="screenshot/android/score_keeptrying.png" alt="Score keep trying" style="width:100%;height:auto;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,0.08);" />
    <figcaption style="font-size:13px;margin-top:6px;color:#444;">Score — Keep trying</figcaption>
  </figure>
</div>

## Contributing

Contributions are welcome. Open an issue or submit a pull request for bug fixes, UI improvements, or additional features (more categories, question sources, analytics, etc.).

## License

This project does not include a license file. Add a `LICENSE` if you intend to publish or share the app under a specific license.
