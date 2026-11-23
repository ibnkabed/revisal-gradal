import SwiftUI

/// The built-in AI in the settings (#BuildHybridAI, 2026-11-23): ready with no key, and whether Apple's on-device
/// model can answer on this phone. The student's own keys below it stay as a fallback.
struct BuiltInAISection: View {
    @ObservedObject private var hybrid = FirebaseHybrid.shared

    var body: some View {
        Section {
            Label("جاهز بلا مفتاح: Gemini عبر Firebase AI Logic", systemImage: "checkmark.seal.fill")
                .foregroundColor(.green)
            LabeledContent("نموذج Apple على هذا الجوال",
                           value: hybrid.onDeviceReady ? L("متاح") : L("غير متاح هنا"))
        } header: {
            Text("الذكاء الاصطناعي المدمج")
        } footer: {
            Text("الطلب القصير بلغة يدعمها نموذج Apple على الجهاز، مثل الإنجليزية، يُجاب على الجوال نفسه بخصوصية وبلا إنترنت. وما سواه، كالكتب الطويلة والعربية والصور، يجيبه Gemini في السحابة عبر Firebase AI Logic. ومفاتيحك أدناه اختيارية، احتياطًا.")
        }
    }
}

/// Which engine wrote an answer, shown small under it.
struct EngineBadge: View {
    let engine: FirebaseHybrid.Engine

    var body: some View {
        Label(engine == .onDevice ? L("أُجيب على هذا الجوال (نموذج Apple)") : L("أجابه Gemini في السحابة (Firebase AI Logic)"),
              systemImage: engine == .onDevice ? "iphone" : "cloud")
            .font(.caption2)
            .foregroundColor(.secondary)
    }
}
