import SwiftUI
import AppKit

struct ExtractView: View {
    @Environment(ProcessRunner.self) private var runner
    @Environment(LocaleManager.self) private var locale
    @State private var archivePath = ""
    @State private var outputDir = ""
    @State private var password = ""
    @State private var modeFullPath = true
    @State private var overwrite = "a"

    private let overwriteModes: [(String, String)] = [
        ("a", "extract.ow.all"), ("s", "extract.ow.skip"),
        ("t", "extract.ow.older"), ("u", "extract.ow.rename"),
        ("ask", "extract.ow.ask"),
    ]

    var body: some View {
        VSplitLayout(runner: runner) {
            GroupBox(locale.t("extract.input")) {
                HStack {
                    TextField(locale.t("extract.archivePath"), text: $archivePath)
                    Button(locale.t("shared.browse")) { chooseArchive() }
                }
                .padding(8)
            }

            GroupBox(locale.t("extract.output")) {
                HStack {
                    TextField(locale.t("extract.outputDir"), text: $outputDir)
                    Button(locale.t("shared.browse")) { chooseOutputDir() }
                }
                .padding(8)
            }

            GroupBox(locale.t("compress.options")) {
                VStack(alignment: .leading, spacing: 10) {
                    SecureField(locale.t("extract.password"), text: $password).frame(maxWidth: 250)
                    Picker(locale.t("extract.mode"), selection: $modeFullPath) {
                        Text(locale.t("extract.mode.full")).tag(true)
                        Text(locale.t("extract.mode.flat")).tag(false)
                    }
                    Picker(locale.t("extract.overwrite"), selection: $overwrite) {
                        ForEach(overwriteModes, id: \.0) { mode, key in
                            Text(locale.t(key)).tag(mode)
                        }
                    }
                }
                .padding(8)
            }

            HStack {
                Button(action: start) { Label(locale.t("extract.start"), systemImage: "play.fill") }
                    .keyboardShortcut(.defaultAction)
                    .disabled(runner.isRunning || archivePath.isEmpty)
                Button(locale.t("extract.cancel")) { runner.cancel() }.disabled(!runner.isRunning)
            }

            if runner.isRunning {
                ProgressView(value: runner.progress) { Text("\(Int(runner.progress * 100))%") }
            }
        }
    }

    private func chooseArchive() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false; panel.canChooseFiles = true; panel.canChooseDirectories = false
        if panel.runModal() == .OK { archivePath = panel.url?.path ?? "" }
    }

    private func chooseOutputDir() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false; panel.canChooseDirectories = true; panel.canChooseFiles = false
        panel.prompt = locale.t("shared.browse")
        if panel.runModal() == .OK { outputDir = panel.url?.path ?? "" }
    }

    private func start() {
        let cmd = modeFullPath ? "x" : "e"
        var args = [cmd, "-bsp1", "-y", archivePath]
        let out = outputDir.isEmpty ? (archivePath as NSString).deletingLastPathComponent : outputDir
        args += ["-o\(out)"]
        if !password.isEmpty { args += ["-p\(password)"] }
        if overwrite != "ask" { args += ["-ao\(overwrite)"] }
        runner.run(args)
    }
}
