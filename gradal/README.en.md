<p align="center"><img src="docs/icon.png" width="128" alt="Gradal app icon"></p>

<h1 align="center">Gradal: AI-written quizzes, graded with the phone camera</h1>

<p align="center"><a href="README.md">العربية</a> · <a href="https://github.com/ibnkabed/revisal-gradal/releases">Releases</a></p>

Gradal is a free, open-source iPhone app for teachers. It works alone, with no computer.

Add a textbook as a PDF, in any subject, in Arabic or English, and Gradal writes the quiz questions. It then prepares the question paper, the answer model and an answer sheet with each student's name. You print them from the phone, grade the sheets with its camera in seconds, and share the gradebook as an Excel file.

The app shows its interface in Arabic or English, following the phone's language. Each quiz's papers keep that quiz's own language.

## Demo video

This app is the teachers' half of **[Revisal & Gradal](../README.md)**, with Revisal as the other half. The demo video and the Devpost project are linked there.

## What it does

- **Writes questions from your book:** pick the pages, name the paper's parts, and set each part's type and number of questions. You review and edit every question before approving it.
- **Arabic and English papers:**
  - An Arabic paper runs right to left, with the ministry header and the options أ ب ج د.
  - An English paper runs left to right, with the options A B C D.
- **Students imported automatically:** from the Excel or PDF file exported from Noor (the Saudi school system). Gradal finds the classes and numbers every student. You can also paste names or add a student by hand.
- **Prints from the phone:** on any AirPrint printer.
- **Grades with the camera:**
  - Gradal reads the quiz and the student from the sheet itself, and scanning works offline.
  - Each student gets a marked copy: green on the right answer, red on a wrong choice, with each question's score and the total.
- **Results:** every student's score, class statistics, an analysis of every question, and an Excel gradebook with a sheet per class.
- **Your data stays with you:** no account, no server, no subscription.

## Built-in hybrid AI with Firebase AI Logic

Gradal now writes questions with **no key to paste**. Its built-in AI runs requests on the device when it can, and in the cloud when it must:

| Request | Where it runs | Why |
|---|---|---|
| A short request (under the on-device context) in a language Apple's on-device model supports, such as a few pages of an English text | **On the iPhone**, with Apple's Foundation Models framework | Private, free, works offline |
| A long chapter, Arabic content, or a phone without Apple Intelligence | **Gemini in the cloud** through Firebase AI Logic | Large context, and Arabic, which the on-device model doesn't support |
| Scanned book pages, and student lists as PDF | **Gemini in the cloud** (multimodal) | The on-device model takes text only |
| The on-device model fails or is busy | The same request **falls back to the cloud** | The teacher always gets an answer |

**Where it is in the code:**

- [`ios/Gradal/AI/FirebaseHybrid.swift`](ios/Gradal/AI/FirebaseHybrid.swift): the hybrid engine. It imports `FirebaseAILogic`, `FirebaseAppCheck`, `FirebaseRemoteConfig` and `FoundationModels`.
  - **On the device:** `LanguageModelSession(model: SystemLanguageModel.default, …)`, after it checks `isAvailable`, `supportsLocale(_:)` and the prompt's size.
  - **In the cloud on iOS 27:** `LanguageModelSession(model: ai.geminiLanguageModel(name:), …)`, the same Foundation Models API with Gemini behind it.
  - **In the cloud on every iOS version:** `FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(…)` for JSON replies and PDF pages.
- [`ios/Gradal/AI/AIClient.swift`](ios/Gradal/AI/AIClient.swift): every AI call goes through it. The built-in AI is tried first, then any keys the teacher linked. If the teacher also links a key, that second provider checks the written questions against the text.
- [`ios/Gradal/Exam/ExamMaker.swift`](ios/Gradal/Exam/ExamMaker.swift): writes the quiz from the book's pages.
- **Supporting Firebase products:**
  - **App Check** is enforced for AI Logic.
  - **Remote Config** holds `cloud_model`, `cloud_fallback_model` (used when the first model is busy or out of free quota) and `on_device`.

The teacher's own free keys (Gemini, Qwen, Groq, Cerebras, Mistral, OpenRouter, DeepSeek) are still in **Settings**, as an optional fallback.

## Built during #BuildHybridAI (November 2026)

Gradal existed before the hackathon, with AI only through keys the teacher pasted. During the hackathon it gained:

1. **The built-in hybrid AI:** on-device Apple Foundation Models with a Gemini cloud fallback, through Firebase AI Logic.
2. **App Check and Remote Config.** The Firebase config is injected at build time from repository secrets.
3. **A full English interface,** with the layout following the phone's language: `en.lproj/Localizable.strings` and [`Model/Localize.swift`](ios/Gradal/Model/Localize.swift). English sample data comes with it.
4. **A Built-in AI section in Settings,** which shows whether the on-device model is available on the phone.
5. **A demo-recording workflow,** [`demo-video.yml`](.github/workflows/demo-video.yml). It runs the real app in the iOS simulator and records it writing a quiz live through Firebase.

## Install

Download the latest `Gradal-unsigned.ipa` from [Releases](https://github.com/ibnkabed/revisal-gradal/releases) and install it with [Sideloadly](https://sideloadly.io/) and a free Apple ID.

**Requirements:**

- iOS 17 or later.
- The on-device path needs iOS 26 or later on an iPhone with Apple Intelligence turned on.

## Build

The app is built without a Mac on GitHub Actions: [`build-ipa.yml`](.github/workflows/build-ipa.yml) runs on the `xcode-27` runner, and also tests the camera reader on synthetic sheets. To build with the built-in AI, add two repository secrets:

- `GOOGLE_SERVICE_INFO_PLIST_B64`: your app's `GoogleService-Info.plist` in base64. It is never committed.
- `APP_CHECK_DEBUG_TOKEN`: an App Check debug token registered in your Firebase project.

Without them the app still builds, and simply hides the built-in AI.

## License

MIT. You may use, copy, change and share the app for free, as long as the copyright line stays in every copy.

Copyright (c) 2026 IbnKabed
