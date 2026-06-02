import Foundation

@Observable
final class ProcessRunner {
    var output = ""
    var progress = 0.0
    var isRunning = false
    var exitCode: Int32 = 0

    private var process: Process?
    private var pipe: Pipe?

    private static var bundled7zz: URL? {
        guard let url = Bundle.main.resourceURL?.appendingPathComponent("7zz"),
              FileManager.default.isExecutableFile(atPath: url.path) else { return nil }
        return url
    }

    private static var system7zz: URL {
        for path in ["/usr/local/bin/7zz", "/opt/homebrew/bin/7zz"] {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.isExecutableFile(atPath: path) { return url }
        }
        // fallback — hope it's in PATH
        return URL(fileURLWithPath: "/usr/local/bin/7zz")
    }

    func run(_ args: [String]) {
        guard !isRunning else { return }
        isRunning = true
        output = ""
        progress = 0

        let proc = Process()
        proc.executableURL = Self.bundled7zz ?? Self.system7zz
        proc.arguments = args
        proc.currentDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())

        let p = Pipe()
        proc.standardOutput = p
        proc.standardError = p
        process = proc
        pipe = p

        p.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            self?.onOutput(text)
        }

        do {
            try proc.run()
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.output += "\n启动失败: \(error.localizedDescription)\n"
                self?.isRunning = false
            }
            p.fileHandleForReading.readabilityHandler = nil
            return
        }

        // Wait on background
        DispatchQueue.global().async { [weak self] in
            proc.waitUntilExit()
            let code = proc.terminationStatus
            p.fileHandleForReading.readabilityHandler = nil
            DispatchQueue.main.async {
                self?.exitCode = code
                self?.isRunning = false
                self?.process = nil
            }
        }
    }

    func cancel() {
        process?.terminate()
        isRunning = false
    }

    private func onOutput(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.output += text
            // Parse " 34%" from progress lines
            let lines = text.components(separatedBy: CharacterSet(charactersIn: "\r\n\u{08}"))
            for line in lines {
                let t = line.trimmingCharacters(in: .whitespaces)
                if let pctIdx = t.firstIndex(of: "%") {
                    let numStr = t[..<pctIdx].trimmingCharacters(in: .whitespaces)
                    if let v = Int(numStr) {
                        self.progress = Double(v) / 100.0
                    }
                }
            }
        }
    }
}
