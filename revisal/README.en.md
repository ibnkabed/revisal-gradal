# Revisal

**[⬇️ Download the app (Revisal-unsigned.ipa)](https://github.com/ibnkabed/revisal-gradal/releases/latest/download/Revisal-unsigned.ipa)** · [العربية](README.md) · [All releases](https://github.com/ibnkabed/revisal-gradal/releases)

Revisal is a free, open-source iPhone app that helps students review what they studied: for their school subjects, and for Saudi Arabia's national exams, Qudrat (General Aptitude) and Tahsili (Achievement). Every question is multiple choice with four options, and everything is solved on the phone. There's no printing and no paper.

The app shows its interface in Arabic or English, following the phone's language.

**About Qudrat and Tahsili.** These are Saudi Arabia's two national standardized tests, run by the National Center for Assessment (Qiyas). Nearly every secondary-school student who wants to go to university takes them:

- **Qudrat (General Aptitude Test)** measures verbal and quantitative reasoning.
- **Tahsili (Scholastic Achievement Admission Test)** measures what the student learned in math, physics, chemistry and biology across the secondary grades.

Most Saudi universities rank applicants by a composite of the high-school GPA, the Qudrat score and the Tahsili score, with weights each university sets. That makes these exams decisive for admission. Good practice material is mostly paid, and Revisal gives students thousands of practice questions for free, offline.

## Demo video

This app is the students' half of **[Revisal & Gradal](../README.md)**, with Gradal as the other half. The demo video and the Devpost project are linked there.

## What it does

- **Your own curriculum:** add any textbook or summary as a PDF, name its units by their pages, then pick a unit and 1 to 10 questions. AI writes the questions, spread across the unit's sections and skills. **Refresh** brings new questions that weren't asked before.
- **Tahsili and Qudrat banks:** the question banks are bundled and work offline. There are 2,004 Tahsili questions (math, physics, chemistry, biology) and 4,007 Qudrat questions (verbal and quantitative), and no question repeats until the student has gone through the whole bank.
- **Explain:** under every question, the AI explains why the correct answer is right. It runs only when the student asks, and the explanation is saved on the phone.
- **Results:** the score, the score per skill, every answer next to the correct one, and **Retry my mistakes**.
- **Private:** all data stays on the phone. There's no account and no server of our own.

## Built-in hybrid AI with Firebase AI Logic

Revisal works with **no key to paste**. Its built-in AI runs requests on the device when it can, and in the cloud when it must:

| Request | Where it runs | Why |
|---|---|---|
| A short request in a language Apple's on-device model supports, such as **Explain** under an English question | **On the iPhone**, with Apple's Foundation Models framework | Private, free, works offline |
| Long unit text, Arabic content, or a phone without Apple Intelligence | **Gemini in the cloud** through Firebase AI Logic | Large context, and Arabic, which the on-device model doesn't support |
| Scanned PDF pages and question figures | **Gemini in the cloud** (multimodal) | The on-device model takes text only |
| The on-device model fails or is busy | The same request **falls back to the cloud** | The student always gets an answer |

Above each explanation, a small label shows which engine answered: on the iPhone, or Gemini in the cloud. When a cloud model is busy or out of free quota, the request is retried and then sent to a second Gemini model.

**Where it is in the code:**

- [`ios/Revisal/AI/FirebaseHybrid.swift`](ios/Revisal/AI/FirebaseHybrid.swift): the hybrid engine. It imports `FirebaseAILogic`, `FirebaseAppCheck`, `FirebaseRemoteConfig` and `FoundationModels`.
  - **On the device:** `LanguageModelSession(model: SystemLanguageModel.default, …)`, after it checks `isAvailable` and `supportsLocale(_:)` for the prompt's language. The prompt must also fit the 4,096-token context.
  - **In the cloud on iOS 27:** `LanguageModelSession(model: ai.geminiLanguageModel(name:), …)`. This is the same Foundation Models API, with Gemini behind it.
  - **In the cloud on every iOS version:** `FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(…)` for JSON replies and for files (`InlineDataPart`).
- [`ios/Revisal/AI/AIClient.swift`](ios/Revisal/AI/AIClient.swift): `chat(…)` tries the built-in AI first, then any keys the student linked. `gemini(file:…)` sends PDFs and figures to Firebase when no Gemini key is linked.
- [`ios/Revisal/App/RevisalApp.swift`](ios/Revisal/App/RevisalApp.swift): calls `FirebaseHybrid.shared.configure()` at launch.
- **Supporting Firebase products:**
  - **App Check** is enforced for AI Logic.
  - **Remote Config** holds `cloud_model` and `cloud_fallback_model` (the Gemini models' names) and `on_device` (a switch for the on-device path), so none is fixed in the app.

The student's own free keys (Gemini, Qwen, Groq, Cerebras, Mistral, OpenRouter, DeepSeek) are still in **Settings**, as an optional fallback.

## Built during #BuildHybridAI (November 2026)

Revisal existed before the hackathon, with AI only through keys the student pasted. During the hackathon it gained:

1. **The built-in hybrid AI:** on-device Apple Foundation Models with a Gemini cloud fallback, through Firebase AI Logic.
2. **App Check and Remote Config.** The Firebase config is injected at build time from repository secrets.
3. **English explanations for English questions,** so they can run on the device.
4. **A full English interface,** with the layout following the phone's language: `en.lproj/Localizable.strings` and [`Model/Localize.swift`](ios/Revisal/Model/Localize.swift).
5. **A Built-in AI section in Settings,** which shows whether the on-device model is available on the phone, and a label above each answer naming the engine.
6. **A demo-recording workflow,** [`demo-video.yml`](.github/workflows/demo-video.yml). It runs the real app in the iOS simulator, makes live Firebase calls, and records the screens.

## Install

Download the latest `Revisal-unsigned.ipa` from [Releases](https://github.com/ibnkabed/revisal-gradal/releases) and install it with [Sideloadly](https://sideloadly.io/) and a free Apple ID.

**Requirements:**

- iOS 17 or later.
- The on-device path needs iOS 26 or later on an iPhone with Apple Intelligence turned on. Every other phone uses the cloud path.

## Build

The app is built without a Mac on GitHub Actions: [`build-ipa.yml`](.github/workflows/build-ipa.yml) runs on the `xcode-27` runner. To build with the built-in AI, add two repository secrets:

- `GOOGLE_SERVICE_INFO_PLIST_B64`: your app's `GoogleService-Info.plist` in base64. It is never committed.
- `APP_CHECK_DEBUG_TOKEN`: an App Check debug token registered in your Firebase project.

Without them the app still builds, and simply hides the built-in AI.

## License

MIT. You may use, copy, change and share the app for free, as long as the copyright line stays in every copy.

Copyright (c) 2026 IbnKabed
