# Contributing to Revisal & Gradal

Thank you for helping improve Gradal (the teacher's app) and Revisal (the student's app).

## Report a bug or a wrong question

Open an [issue](https://github.com/ibnkabed/revisal-gradal-firebase/issues) and include:

- The app (Gradal or Revisal) and its version from **Settings**.
- What you did, what you expected, and what happened, with a screenshot if you can.
- For a wrong question in Revisal: the section (curriculum, Tahsili or Qudrat), the subject or skill, the question as shown, and the answer you believe is right with its reason.

## Suggest a feature

Open an issue that explains the idea and how it helps teachers or students.

## Change the code

1. Fork the repository and create a branch for your change.
2. Each app is generated with XcodeGen from its own `ios/project.yml` (`gradal/ios/`, `revisal/ios/`). Gradal's sheet reader is checked by `OMRCheck`, and Revisal's review rules and banks by `RevisalCheck`.
3. Open a pull request that explains the change; GitHub Actions checks it.

Never put keys, passwords or personal data in an issue or a change.
