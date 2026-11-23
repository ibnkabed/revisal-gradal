import Foundation

/// The interface language (#BuildHybridAI, 2026-11-23): the app follows the phone's language. The Arabic text in
/// the code is the key; `en.lproj/Localizable.strings` holds its English, and an Arabic phone shows the key itself.
/// Foundation-only, so the checks tool (macOS, no string tables) keeps the Arabic and its tests stay as they are.

/// The interface text for `key` (Arabic) in the phone's language.
func L(_ key: String) -> String {
    Bundle.main.localizedString(forKey: key, value: key, table: nil)
}

/// The same with `%@` arguments, in order (pass numbers as strings: "\(n)").
func L(_ key: String, _ args: CVarArg...) -> String {
    String(format: L(key), arguments: args)
}

enum Lang {
    /// True when the interface is Arabic: an Arabic phone, or a bundle with no English table (the checks tool).
    static let isArabic: Bool = {
        guard Bundle.main.path(forResource: "Localizable", ofType: "strings", inDirectory: nil,
                               forLocalization: "en") != nil else { return true }
        return (Bundle.main.preferredLocalizations.first ?? "ar").hasPrefix("ar")
    }()

    /// English nouns for the Arabic counted forms (keyed by the `many` form).
    static let englishNouns: [String: String] = [
        "سؤالًا": "question", "صفحة": "page", "وحدة": "unit", "مهارة": "skill",
        "طالبًا": "student", "ورقة": "sheet", "فصلًا": "class", "اختبارًا": "quiz", "فقرة": "item",
    ]
}
