import SwiftUI

struct QuickExtractView: View {
    let archiveURL: URL
    let onBack: () -> Void

    @Environment(ProcessRunner.self) private var runner
    @Environment(LocaleManager.self) private var locale
    @State private var password = ""
    @State private var finished = false
    @State private var success = false

    private var archiveName: String { archiveURL.lastPathComponent }
    private var outputDir: String { archiveURL.deletingLastPathComponent().path }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(archiveName)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1).truncationMode(.middle)

            SecureField(locale.t("quick.password"), text: $password)
                .font(.system(size: 12))
                .disabled(runner.isRunning)
                .frame(height: 24)

            HStack(spacing: 10) {
                if !finished {
                    Button(action: start) {
                        Text(locale.t("quick.extract")).frame(width: 64)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(runner.isRunning).controlSize(.small)
                } else if !success {
                    Button(action: start) {
                        Text(locale.t("quick.retry")).frame(width: 64)
                    }
                    .keyboardShortcut(.defaultAction)
                    .controlSize(.small)
                }

                if runner.isRunning {
                    Button(locale.t("quick.cancel")) { runner.cancel() }.controlSize(.small)
                } else {
                    Button(locale.t("quick.close")) { NSApplication.shared.terminate(nil) }.controlSize(.small)
                }
            }

            HStack(spacing: 8) {
                ProgressView(value: runner.progress)
                    .frame(maxWidth: .infinity)
                Text("\(Int(runner.progress * 100))%")
                    .font(.system(size: 11)).monospacedDigit()
                    .frame(width: 36, alignment: .trailing)
            }

            Label(
                runner.isRunning
                    ? locale.t("quick.extracting")
                    : (finished
                        ? (success ? locale.t("quick.done") : locale.t("quick.failed"))
                        : locale.t("quick.ready")),
                systemImage: runner.isRunning
                    ? "arrow.down.circle.fill"
                    : (finished
                        ? (success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        : "circle.fill")
            )
            .font(.system(size: 12))
            .foregroundColor(
                runner.isRunning
                    ? Color(red: 0.886, green: 0.137, blue: 0.388)
                    : (finished ? (success ? .green : .red) : .cyan)
            )
        }
        .padding(14)
        .onChange(of: archiveURL) { _, _ in
            password = ""
            finished = false
            success = false
            runner.output = ""
            runner.progress = 0
        }
        .onChange(of: runner.isRunning) { _, running in
            if !running && !runner.output.isEmpty {
                finished = true
                success = runner.exitCode == 0
            }
        }
    }

    private func start() {
        finished = false
        success = false
        var args = ["x", "-bsp1", "-y", archiveURL.path, "-o\(outputDir)"]
        if !password.isEmpty { args += ["-p\(password)"] }
        runner.run(args)
    }
}
