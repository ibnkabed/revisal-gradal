# Revisal & Gradal

**One free, open-source iPhone project for the classroom, in two apps: Gradal for the teacher, Revisal for the student. Both run on the same built-in hybrid AI through Firebase AI Logic: on the iPhone with Apple's on-device model when it can, and with Gemini in the cloud when it must. No key to paste.**

<!-- DEMO-VIDEO -->

| | **Gradal**, for the teacher | **Revisal**, for the student |
|---|---|---|
| Job | Writes quizzes from the textbook, prints the papers, grades them with the camera | Reviews what the student studied, with questions solved on the phone |
| AI | Writes the questions from the book's pages | Writes review questions from the book, and explains any answer on request |
| Also | Students imported from Excel or PDF, offline camera grading, results and an Excel gradebook | 6,011 bundled Qudrat and Tahsili questions that work offline, results by skill, retry my mistakes |
| Download | [Gradal-unsigned.ipa](https://github.com/ibnkabed/gradal/releases/latest/download/Gradal-unsigned.ipa) | [Revisal-unsigned.ipa](https://github.com/ibnkabed/revisal/releases/latest/download/Revisal-unsigned.ipa) |
| Code | [`gradal/`](gradal/) | [`revisal/`](revisal/) |

Each user installs the app for their role: a teacher takes Gradal, a student takes Revisal. They were built as two apps because each is a full app on its own, and one app holding both would be heavy for everyone.

## One hybrid AI engine for both

Both apps share one engine, `FirebaseHybrid.swift` ([Gradal's copy](gradal/ios/Gradal/AI/FirebaseHybrid.swift), [Revisal's copy](revisal/ios/Revisal/AI/FirebaseHybrid.swift), identical):

| Request | Where it runs | Why |
|---|---|---|
| A short request in a language Apple's on-device model supports, such as a few pages of an English text or one explanation | **On the iPhone**, with Apple's Foundation Models | Private, free, works offline |
| A long chapter, Arabic content, or a phone without Apple Intelligence | **Gemini in the cloud** through Firebase AI Logic | Large context, and Arabic, which the on-device model doesn't support yet |
| Scanned book pages and PDF student lists | **Gemini in the cloud** (multimodal) | The on-device model takes text only |
| The on-device model fails, or a cloud model is busy | **Falls back** to the cloud, then to a second Gemini model | The user always gets an answer |

- **On the device:** `LanguageModelSession(model: SystemLanguageModel.default, …)`, after checking `isAvailable`, `supportsLocale(_:)` and the prompt's size.
- **In the cloud:** `FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(…)` for JSON and PDF pages, and on iOS 27 `ai.geminiLanguageModel(name:)` in the same Foundation Models API.
- **App Check** is enforced for AI Logic, and **Remote Config** holds the cloud model names and an on-device switch.

## Install

1. Download the IPA for your role from the table above.
2. Install it with [Sideloadly](https://sideloadly.io/) and a free Apple ID, on iOS 17 or later.
3. Open **Settings → Built-in AI**: it shows "Ready with no key" and whether Apple's on-device model is available.

Each app's own README has the full guide: [Gradal](gradal/README.en.md) · [Revisal](revisal/README.en.md).

## Build

There is no Mac in this project: everything builds on GitHub Actions. [`build.yml`](.github/workflows/build.yml) checks and builds both apps as unsigned IPAs (XcodeGen, the `xcode-27` runner). The built-in AI needs a Firebase project's `GoogleService-Info.plist` for each app and an App Check debug token as repository secrets; without them each app builds with the built-in AI left out.

## License

MIT, Copyright (c) 2026 IbnKabed. See [LICENSE](LICENSE).
