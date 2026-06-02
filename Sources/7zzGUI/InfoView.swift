import SwiftUI
import AppKit

struct InfoView: View {
    @Environment(ProcessRunner.self) private var runner
    @Environment(LocaleManager.self) private var locale
    @State private var archivePath = ""
    @State private var command = "l"
    @State private var showTechInfo = false

    private let commands: [(String, String)] = [
        ("l", "info.cmd.list"), ("t", "info.cmd.test"), ("h", "info.cmd.hash"), ("b", "info.cmd.benchmark"),
    ]

    var body: some View {
        VSplitLayout(runner: runner) {
            GroupBox(locale.t("info.input")) {
                HStack {
                    TextField(command == "h" ? locale.t("compress.archivePath") : locale.t("info.path"), text: $archivePath)
                        .disabled(command == "b")
                    Button(locale.t("shared.browse")) { choosePath() }
                        .disabled(command == "b")
                }
                .padding(8)
            }

            GroupBox(locale.t("info.command")) {
                VStack(alignment: .leading, spacing: 10) {
                    Picker(locale.t("info.command"), selection: $command) {
                        ForEach(commands, id: \.0) { cmd, key in Text(locale.t(key)).tag(cmd) }
                    }
                    .pickerStyle(.radioGroup)
                    Toggle(locale.t("info.techInfo"), isOn: $showTechInfo).disabled(command == "h" || command == "b")
                }
                .padding(8)
            }

            HStack {
                Button(action: start) { Label(locale.t("info.execute"), systemImage: "play.fill") }
                    .keyboardShortcut(.defaultAction)
                    .disabled(runner.isRunning || (command != "b" && archivePath.isEmpty))
                Button(locale.t("shared.cancel")) { runner.cancel() }.disabled(!runner.isRunning)
            }
        }
    }

    private func choosePath() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = command == "h"
        panel.canChooseFiles = true
        if panel.runModal() == .OK { archivePath = panel.url?.path ?? "" }
    }

    private func start() {
        var args = command == "b" ? ["b"] : [command, archivePath, "-y"]
        if showTechInfo && command == "l" { args.append("-slt") }
        runner.run(args)
    }
}
