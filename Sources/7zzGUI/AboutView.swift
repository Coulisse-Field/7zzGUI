import SwiftUI

struct AboutView: View {
    @Environment(LocaleManager.self) private var locale

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)

            Text("7zzGUI")
                .font(.system(size: 16, weight: .bold))

            Text("\(locale.t("about.version")) \(version)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(32)
        .frame(width: 260, height: 220)
    }
}
