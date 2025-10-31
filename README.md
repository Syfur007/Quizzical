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

<!-- Use a fixed table layout and the width attribute on images so thumbnails stay at a fixed pixel size and don't stretch -->
<table style="table-layout:fixed; width:660px; margin:0 auto; border-collapse:collapse;">
  <colgroup>
    <col style="width:220px;" />
    <col style="width:220px;" />
    <col style="width:220px;" />
  </colgroup>
  <tr>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/home.png" alt="Home" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Home</div>
    </td>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/categories.png" alt="Categories" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Categories</div>
    </td>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/quiz_configure1.png" alt="Quiz configure 1" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Quiz configuration (1)</div>
    </td>
  </tr>
  <tr>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/quiz_configure2.png" alt="Quiz configure 2" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Quiz configuration (2)</div>
    </td>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/correct_answer.png" alt="Correct answer" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Correct answer</div>
    </td>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/wrong_answer.png" alt="Wrong answer" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Wrong answer</div>
    </td>
  </tr>
  <tr>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/score_excellent.png" alt="Score excellent" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Score — Excellent</div>
    </td>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/score_notbad.png" alt="Score not bad" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Score — Not bad</div>
    </td>
    <td style="padding:8px; vertical-align:top; text-align:center;">
      <img src="screenshot/android/score_keeptrying.png" alt="Score keep trying" style="width:220px!important; max-width:220px!important; height:auto!important; display:block; margin:0 auto; border-radius:6px;" />
      <div style="font-size:13px;color:#444;margin-top:6px;">Score — Keep trying</div>
    </td>
  </tr>
</table>

> Note: If images do not display in your environment (for example some Git hosts require special handling), open the referenced files directly under `screenshot/android/`.

## Contributing

Contributions are welcome. Open an issue or submit a pull request for bug fixes, UI improvements, or additional features (more categories, question sources, analytics, etc.).

## License

This project does not include a license file. Add a `LICENSE` if you intend to publish or share the app under a specific license.
