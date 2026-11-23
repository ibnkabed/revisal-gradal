import Foundation

/// `english` opens an English curriculum review and `explain` asks for its first explanation live, through the
/// built-in AI (#BuildHybridAI demo video, 2026-11-23).
/// Screenshot mode for the README (2026-11-02): `-demo <screen>` opens the app on sample data in a folder of
/// its own, never the student's. Screens: curricula, bank, question, answered, result, settings. The CI job
/// `screenshots.yml` launches each one in the simulator and saves the screen.
enum Demo {
    static let screen: String? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-demo"), i + 1 < args.count else { return nil }
        return args[i + 1]
    }()

    /// The tab the screen lives in: 0 المنهج, 1 التحصيلي, 2 القدرات, 3 الإعدادات.
    static var tab: Int {
        switch screen {
        case "curricula", "english", "explain": return 0
        case "answered": return 1
        case "settings": return 3
        default: return 2
        }
    }

    /// The review opened over the tab, if the screen is one.
    static var openSet: String? {
        switch screen {
        case "question": return "demo-quant"
        case "answered": return "demo-physics"
        case "result": return "demo-result"
        case "english", "explain": return "demo-english"
        default: return nil
        }
    }

    /// A fresh folder with one book, three reviews, an explanation and bank progress.
    @MainActor
    static func folder() -> URL {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("RevisalDemo", isDirectory: true)
        try? FileManager.default.removeItem(at: folder)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var db = StoreFile()

        let ar = Lang.isArabic
        var book = Book(id: "demo-book", name: ar ? "الأحياء ٣ — ملخص الفصل الأول" : "Biology 3 — Chapter 1 summary",
                        pages: 48, size: 2_400_000, addedAt: Stamp.now())
        book.subject = ar ? "الأحياء" : "Biology"
        var unit = Unit(name: ar ? "الوراثة الجزيئية" : "Molecular genetics", pageFrom: 1, pageTo: 16)
        unit.skills = ar ? ["تركيب DNA", "تضاعف DNA", "بناء البروتين", "الطفرات"]
                         : ["DNA structure", "DNA replication", "Protein synthesis", "Mutations"]
        book.units = [unit, Unit(name: ar ? "الجهاز العصبي" : "The nervous system", pageFrom: 17, pageTo: 32),
                      Unit(name: ar ? "الهرمونات" : "Hormones", pageFrom: 33, pageTo: 48)]
        db.books = [book]

        let qudurat = BankStore.bank(.qudurat)?.questions ?? []
        let tahsili = BankStore.bank(.tahsili)?.questions ?? []
        let quant = qudurat.filter { $0.section == "quant" && $0.image == nil }
        let comparison = quant.filter { ReviewRules.fixedOrder($0) }
        let quantSet = Array((comparison.prefix(1) + quant.filter { !ReviewRules.fixedOrder($0) }.prefix(9)))
        let physics = Array(tahsili.filter { $0.section == "physics" && $0.image == nil && $0.text.count < 120 }.prefix(10))
        let verbal = Array(qudurat.filter { $0.section == "verbal" }.prefix(10))

        var sets: [ReviewSet] = []
        // An English curriculum review (an English summary), for the English screens and the on-device demo.
        let english = [
            ReviewQuestion(skill: "DNA structure", text: "Which base pairs with adenine in DNA?",
                           options: ["Thymine", "Guanine", "Cytosine", "Uracil"], answer: 0, explanation: ""),
            ReviewQuestion(skill: "DNA replication", text: "Why is DNA replication called semi-conservative?",
                           options: ["Each new molecule keeps one original strand", "Half of the genes are copied",
                                     "Only one strand is ever copied", "The copy is made from RNA"], answer: 0, explanation: ""),
            ReviewQuestion(skill: "Protein synthesis", text: "Where does translation take place in the cell?",
                           options: ["In the nucleus", "On the ribosomes", "In the mitochondria", "In the cell membrane"],
                           answer: 1, explanation: ""),
            ReviewQuestion(skill: "Mutations", text: "A mutation that replaces one base with another is called a:",
                           options: ["Deletion", "Insertion", "Point substitution", "Duplication"], answer: 2, explanation: ""),
            ReviewQuestion(skill: "Protein synthesis", text: "Which molecule carries amino acids to the ribosome?",
                           options: ["mRNA", "rRNA", "tRNA", "DNA polymerase"], answer: 2, explanation: ""),
        ]
        var en = ReviewSet(title: book.name + " · " + unit.name,
                           source: ReviewSource(track: .curriculum, bookId: book.id, unitId: unit.id, count: english.count), questions: english)
        en.id = "demo-english"
        en.unitId = unit.id
        if screen == "explain" { en.choices[0] = 1 }
        sets.append(en)
        if !quantSet.isEmpty {
            var s = ReviewSet(title: L("القدرات") + " · " + L("الكمي"), source: ReviewSource(track: .qudurat, section: "quant", count: 10),
                              questions: quantSet)
            s.id = "demo-quant"
            sets.append(s)
        }
        if let first = physics.first {
            var s = ReviewSet(title: L("التحصيلي") + " · " + L("الفيزياء"), source: ReviewSource(track: .tahsili, section: "physics", count: 10),
                              questions: physics)
            s.id = "demo-physics"
            s.choices[0] = (first.answer + 1) % 4
            sets.append(s)
            db.explanations[first.id] = "الإجابة الصحيحة «\(first.options[first.answer])»: "
                + "هذا ما يعطيه القانون مباشرة عند التعويض بالقيم المعطاة في السؤال، أما الخيار الذي اخترته فينتج عن "
                + "الخلط بين الكميتين، فتأكد من وحدة كل منهما قبل التعويض."
        }
        if !verbal.isEmpty {
            var s = ReviewSet(title: L("القدرات") + " · " + L("اللفظي"), source: ReviewSource(track: .qudurat, section: "verbal", count: 10),
                              questions: verbal)
            s.id = "demo-result"
            for (i, q) in verbal.enumerated() { s.choices[i] = [1, 4, 7].contains(i) ? (q.answer + 1) % 4 : q.answer }
            s.finishedAt = Stamp.now()
            sets.append(s)
        }
        db.sets = sets
        db.bankSeen[Bank.seenKey(.qudurat)] = Array(qudurat.prefix(qudurat.count / 3).map(\.id))
        db.bankSeen[Bank.seenKey(.tahsili)] = Array(tahsili.prefix(tahsili.count / 5).map(\.id))
        if let data = try? JSONEncoder().encode(db) {
            try? data.write(to: folder.appendingPathComponent("store.json"))
        }
        return folder
    }
}
