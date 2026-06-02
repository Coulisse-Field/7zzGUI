import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(LocaleManager.self) private var locale
    @State private var runner = ProcessRunner()
    @State private var extractURL: URL?

    var body: some View {
        ZStack {
            if let url = extractURL {
                QuickExtractView(archiveURL: url) {
                    extractURL = nil
                    appDelegate.extractURL = nil
                }
                .environment(runner)
                .frame(width: 340, height: 150)
            } else {
                TabView {
                    CompressView()
                        .tabItem { Label(locale.t("tab.compress"), systemImage: "archivebox.fill") }
                    ExtractView()
                        .tabItem { Label(locale.t("tab.extract"), systemImage: "archivebox") }
                    InfoView()
                        .tabItem { Label(locale.t("tab.info"), systemImage: "info.circle") }
                }
                .frame(width: 575, height: 750)
                .environment(runner)
            }
        }
        .animation(.none, value: extractURL)
        .onChange(of: extractURL) { _, url in
            if let window = NSApp.keyWindow {
                if url != nil {
                    window.setContentSize(NSSize(width: 340, height: 150))
                } else {
                    window.setContentSize(NSSize(width: 575, height: 750))
                }
                window.center()
            }
        }
        .onChange(of: appDelegate.extractURL) { _, url in
            if let url { extractURL = url }
        }
    }
}
