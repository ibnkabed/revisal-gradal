import Foundation
import UIKit

/// Screenshot mode for the README (2026-11-02): `-demo <screen>` opens the app on sample classes, tests and
/// graded papers in a folder of its own, never the teacher's. Screens: quizzes, detail, students, settings, about (settings scrolled to «عن التطبيق»).
/// The CI job `screenshots.yml` launches each one in the simulator and saves the screen.
enum Demo {
    static let screen: String? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-demo"), i + 1 < args.count else { return nil }
        return args[i + 1]
    }()

    /// The tab the screen lives in: 0 الاختبارات, 1 الطلاب, 2 الإعدادات.
    static var tab: Int {
        switch screen {
        case "students": return 1
        case "settings", "about": return 2
        default: return 0
        }
    }

    /// `write`: the sample English book added by `seed`, from which the new-quiz form writes a quiz live through
    /// the built-in AI (#BuildHybridAI demo video, 2026-11-23).
    static var writeBookId: String?

    /// The test opened in the tests tab (its results), set by `seed`.
    static var openQuiz: String?

    /// A two-page English science text as a PDF, added to the store; its id.
    @MainActor
    private static func sampleBook(_ store: Store) -> String? {
        let pages = [
            "The Water Cycle\n\nWater on Earth moves in a continuous cycle. The Sun heats water in oceans, lakes and rivers, "
            + "and the water evaporates, turning from a liquid into water vapour that rises into the air. Plants also release "
            + "water vapour through their leaves in a process called transpiration.\n\nAs the warm, moist air rises it cools. "
            + "Cooler air cannot hold as much water vapour, so the vapour condenses into tiny droplets of liquid water. These "
            + "droplets gather around particles of dust to form clouds. This change from gas to liquid is called condensation.",
            "Precipitation and Collection\n\nWhen the droplets in a cloud join together and become too heavy, they fall to the "
            + "ground as precipitation: rain, snow, sleet or hail, depending on the temperature. Some of the water soaks into "
            + "the ground and becomes groundwater; this is called infiltration. The rest flows over the land as run-off into "
            + "streams, rivers and finally the oceans, where the cycle begins again.\n\nThe water cycle moves heat around the "
            + "planet, shapes the weather, and supplies the fresh water that living things need. Without it, the land would "
            + "quickly dry out.",
        ]
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        let data = renderer.pdfData { ctx in
            for text in pages {
                ctx.beginPage()
                (text as NSString).draw(in: CGRect(x: 56, y: 64, width: 483, height: 714),
                                        withAttributes: [.font: UIFont.systemFont(ofSize: 15)])
            }
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("The Water Cycle.pdf")
        guard (try? data.write(to: url)) != nil else { return nil }
        return try? store.addBook(from: url).id
    }

    static func folder() -> URL {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("GradalDemo", isDirectory: true)
        try? FileManager.default.removeItem(at: folder)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    /// Two classes, two tests with keys, and graded papers for the first test.
    @MainActor
    static func seed(_ store: Store) {
        let names1 = ["عبدالرحمن خالد العتيبي", "فيصل سعد القحطاني", "محمد عبدالله الشهري", "نواف فهد الدوسري",
                      "سلمان ناصر الغامدي", "يوسف أحمد الزهراني", "تركي سعود المطيري", "عمر حسن الحربي",
                      "زياد علي السبيعي", "مشاري ماجد العنزي"]
        let names2 = ["بدر صالح الشمري", "راكان عادل القرني", "حمد إبراهيم المالكي", "ريان طلال العمري",
                      "سعود منصور الرشيدي", "خالد وليد الجهني"]
        // the English interface gets English sample data (#BuildHybridAI, 2026-11-23)
        let ar = Lang.isArabic
        let enNames1 = ["Adam Carter", "Ben Hughes", "Chris Walker", "Daniel Price", "Ethan Brooks", "Felix Grant",
                        "George Hall", "Henry Lewis", "Isaac Moore", "Jack Turner"]
        let enNames2 = ["Liam Scott", "Mason Reed", "Noah Bennett", "Oliver King", "Peter Wood", "Ryan Cooper"]
        _ = try? store.pasteStudents((ar ? names1 : enNames1).joined(separator: "\n"), className: ar ? "٣/١" : "Grade 9A")
        _ = try? store.pasteStudents((ar ? names2 : enNames2).joined(separator: "\n"), className: ar ? "٣/٢" : "Grade 9B")
        let classIds = store.db.classes.map(\.id)
        let letters = ["A", "B", "C", "D"]
        let key = (0..<20).map { letters[($0 * 7 + 3) % 4] }
        guard let quiz = try? store.saveManualQuiz(id: nil, name: ar ? "اختبار الفترة الأولى" : "Term 1 test",
                                                   subject: ar ? "الرياضيات" : "English",
                                                   language: ar ? "ar" : "en", classIds: classIds, key: key) else { return }
        _ = try? store.saveManualQuiz(id: nil, name: ar ? "اختبار قصير: الكسور" : "Quiz: past tense",
                                      subject: ar ? "الرياضيات" : "English",
                                      language: ar ? "ar" : "en", classIds: classIds,
                                      key: (0..<10).map { letters[($0 * 3 + 1) % 4] })
        // each student misses a different number of questions, so the results and the analysis vary
        for (n, student) in store.db.students.prefix(13).enumerated() {
            var answers = key
            for q in 0..<((n * 3) % 9) { answers[(q * 5 + n) % key.count] = letters[(letters.firstIndex(of: key[(q * 5 + n) % key.count])! + 1) % 4] }
            store.addDemoScan(quizId: quiz.id, studentId: student.id, answers: answers)
        }
        openQuiz = screen == "detail" ? quiz.id : nil
        if screen == "write" { writeBookId = sampleBook(store) }
    }
}
