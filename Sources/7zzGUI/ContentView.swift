import SwiftUI

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    private var bgColor: Color {
        if isSelected { return Color.primary.opacity(0.10) }
        if isHovered { return Color.primary.opacity(0.05) }
        return .clear
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .frame(width: 80, height: 48)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .contentShape(Rectangle())
        .onTapGesture { action() }
        .onHover { isHovered = $0 }
    }
}

struct ContentView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(LocaleManager.self) private var locale
    @State private var runner = ProcessRunner()
    @State private var extractURL: URL?
    @State private var selectedTab = 0

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
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        TabButton(icon: "archivebox.fill", label: locale.t("tab.compress"), isSelected: selectedTab == 0) { selectedTab = 0 }
                        TabButton(icon: "archivebox", label: locale.t("tab.extract"), isSelected: selectedTab == 1) { selectedTab = 1 }
                        TabButton(icon: "info.circle", label: locale.t("tab.info"), isSelected: selectedTab == 2) { selectedTab = 2 }
                    }
                    .padding(.horizontal, 12).padding(.top, 10).padding(.bottom, 6)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Divider()

                    ZStack {
                        CompressView().opacity(selectedTab == 0 ? 1 : 0)
                        ExtractView().opacity(selectedTab == 1 ? 1 : 0)
                        InfoView().opacity(selectedTab == 2 ? 1 : 0)
                    }
                    .environment(runner)
                }
                .frame(width: 575, height: 675)
            }
        }
        .animation(.none, value: extractURL)
        .onChange(of: extractURL) { _, url in
            if let window = NSApp.keyWindow {
                if url != nil {
                    window.setContentSize(NSSize(width: 340, height: 150))
                } else {
                    window.setContentSize(NSSize(width: 575, height: 675))
                }
                window.center()
            }
        }
        .onChange(of: appDelegate.extractURL) { _, url in
            if let url { extractURL = url }
        }
    }
}
