import Foundation

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

struct Language: Hashable, Codable {
    let code: String
    let displayName: String
}

@Observable
final class LocaleManager {
    private static var strings: [String: [String: String]] = [:]
    private static var availableLanguages: [Language] = []
    private static let langDir: URL? = {
        // 1. .app/Contents/Resources/language/
        if let r = Bundle.main.resourceURL?.appendingPathComponent("language"),
           FileManager.default.fileExists(atPath: r.path) { return r }
        // 2. SPM resource bundle (development / fallback)
        if let r = Bundle.module.resourceURL?.appendingPathComponent("language"),
           FileManager.default.fileExists(atPath: r.path) { return r }
        return nil
    }()

    var language: Language {
        didSet {
            UserDefaults.standard.set(language.code, forKey: "appLanguage")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }

    init() {
        Self.discoverLanguages()
        let savedCode = UserDefaults.standard.string(forKey: "appLanguage")
        if let saved = savedCode, let match = Self.availableLanguages.first(where: { $0.code == saved }) {
            language = match
        } else {
            language = Self.detectSystemLanguage()
        }
    }

    var availableLanguages: [Language] { Self.availableLanguages }

    private static func discoverLanguages() {
        guard let dir = langDir,
              let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        else { return }

        var langs: [Language] = []
        var newStrings: [String: [String: String]] = [:]

        for file in files where file.pathExtension == "lan" {
            let code = file.deletingPathExtension().lastPathComponent
            guard let content = try? String(contentsOf: file, encoding: .utf8) else { continue }

            var displayName = code
            var kv: [String: String] = [:]

            for line in content.components(separatedBy: "\n") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
                guard let eqRange = trimmed.range(of: " = ") else { continue }
                let key = trimmed[..<eqRange.lowerBound].trimmingCharacters(in: .whitespaces)
                let value = String(trimmed[eqRange.upperBound...])
                if key == "@language.name" { displayName = value }
                else { kv[key] = value }
            }

            langs.append(Language(code: code, displayName: displayName))
            for (key, val) in kv { newStrings[key, default: [:]][code] = val }
        }

        availableLanguages = langs.sorted { $0.code < $1.code }
        strings = newStrings
    }

    private static func detectSystemLanguage() -> Language {
        let p = Locale.preferredLanguages.first ?? ""
        let short = String(p.prefix(while: { $0 != "-" && $0 != "_" }))
        if let match = availableLanguages.first(where: { $0.code == short }) { return match }
        return availableLanguages.first(where: { $0.code == "en" })
            ?? availableLanguages.first
            ?? Language(code: "en", displayName: "English")
    }

    func t(_ key: String) -> String {
        Self.strings[key]?[language.code] ?? key
    }
}
