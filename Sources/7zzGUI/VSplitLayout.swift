import SwiftUI

struct VSplitLayout<Content: View>: View {
    @State var runner: ProcessRunner
    @Environment(LocaleManager.self) private var locale
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) { content }
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)

            Divider()

            outputPanel.frame(height: 200)
        }
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(locale.t("shared.outputLog")).font(.headline)
                Spacer()
                if !runner.output.isEmpty {
                    Button(locale.t("shared.clearOutput")) { runner.output = "" }.controlSize(.small)
                }
                Circle().fill(runner.isRunning ? Color.green : Color.gray).frame(width: 8, height: 8)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)

            ScrollViewReader { proxy in
                ScrollView {
                    Text(runner.output)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(8)
                    Color.clear.frame(height: 1).id("bottom")
                }
                .onChange(of: runner.output) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(.horizontal, 8).padding(.bottom, 8)
        }
    }
}
