import SwiftUI
import AppKit

struct CompressView: View {
    @Environment(ProcessRunner.self) private var runner
    @Environment(LocaleManager.self) private var locale
    @State private var sourcePath = ""
    @State private var archivePath = ""
    @State private var format = "7z"
    @State private var compLevel = 5
    @State private var password = ""
    @State private var encryptHeaders = false
    @State private var recursive = true
    @State private var deleteAfter = false
    @State private var splitVolume = ""
    @State private var threads = ""

    private let formats = ["7z", "zip", "tar", "gzip", "bzip2", "xz", "wim"]

    private let levels: [(String, Int)] = [
        ("compress.level.0", 0), ("compress.level.1", 1),
        ("compress.level.3", 3), ("compress.level.5", 5),
        ("compress.level.7", 7), ("compress.level.9", 9),
    ]

    var body: some View {
        VSplitLayout(runner: runner) {
            GroupBox(locale.t("compress.source")) {
                HStack {
                    TextField(locale.t("compress.sourcePath"), text: $sourcePath)
                    Button(locale.t("compress.browse")) { chooseSource() }
                }
                .padding(8)
            }

            GroupBox(locale.t("compress.output")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField(locale.t("compress.archivePath"), text: $archivePath)
                        Button(locale.t("compress.browse")) { chooseArchiveSave() }
                    }
                    Picker(locale.t("compress.format"), selection: $format) {
                        ForEach(formats, id: \.self) { Text($0) }
                    }
                    .onChange(of: format) { updateArchiveName() }
                    Picker(locale.t("compress.level"), selection: $compLevel) {
                        ForEach(levels, id: \.1) { key, val in Text(locale.t(key)).tag(val) }
                    }
                    .pickerStyle(.menu)
                }
                .padding(8)
            }

            GroupBox(locale.t("compress.options")) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        SecureField(locale.t("compress.password"), text: $password).frame(maxWidth: 220)
                        Toggle(locale.t("compress.encryptNames"), isOn: $encryptHeaders).disabled(password.isEmpty)
                    }
                    HStack(spacing: 24) {
                        Toggle(locale.t("compress.recursive"), isOn: $recursive)
                        Toggle(locale.t("compress.deleteAfter"), isOn: $deleteAfter)
                    }
                    HStack(spacing: 12) {
                        TextField(locale.t("compress.splitVolume"), text: $splitVolume).frame(width: 160)
                        TextField(locale.t("compress.threads"), text: $threads).frame(width: 80)
                    }
                }
                .padding(8)
            }

            HStack {
                Button(action: start) { Label(locale.t("compress.start"), systemImage: "play.fill") }
                    .keyboardShortcut(.defaultAction)
                    .disabled(runner.isRunning || sourcePath.isEmpty || archivePath.isEmpty)
                Button(locale.t("compress.cancel")) { runner.cancel() }.disabled(!runner.isRunning)
            }

            if runner.isRunning {
                ProgressView(value: runner.progress) { Text("\(Int(runner.progress * 100))%") }
            }
        }
    }

    private func updateArchiveName() {
        guard !sourcePath.isEmpty, archivePath.isEmpty || archivePath.hasPrefix(NSString(string: sourcePath).deletingLastPathComponent) else { return }
        let dir = (sourcePath as NSString).deletingLastPathComponent
        let name = (sourcePath as NSString).lastPathComponent
        let stem = (name as NSString).deletingPathExtension
        let ext = format == "gzip" ? "gz" : format == "bzip2" ? "bz2" : format
        archivePath = (dir as NSString).appendingPathComponent("\(stem).\(ext)")
    }

    private func chooseSource() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false; panel.canChooseDirectories = true; panel.canChooseFiles = true
        if panel.runModal() == .OK {
            let wasEmpty = sourcePath.isEmpty; sourcePath = panel.url?.path ?? ""
            if wasEmpty { updateArchiveName() }
        }
    }

    private func chooseArchiveSave() {
        let panel = NSSavePanel()
        panel.allowsOtherFileTypes = true
        if !sourcePath.isEmpty { panel.directoryURL = URL(fileURLWithPath: (sourcePath as NSString).deletingLastPathComponent) }
        panel.nameFieldStringValue = "archive.\(format)"
        if panel.runModal() == .OK { archivePath = panel.url?.path ?? "" }
    }

    private func start() {
        var args = ["a", "-bsp1", "-y", archivePath, sourcePath]
        args += ["-t\(format)", "-mx\(compLevel)"]
        if recursive { args.append("-r") }
        if deleteAfter { args.append("-sdel") }
        if !password.isEmpty {
            args.append("-p\(password)")
            if encryptHeaders { args.append("-mhe=on") }
        }
        if !splitVolume.isEmpty { args += ["-v\(splitVolume)"] }
        if !threads.isEmpty, let n = Int(threads) { args += ["-mmt=\(n)"] }
        runner.run(args)
    }
}
